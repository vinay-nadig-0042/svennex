class CreateAutobuildWorker
  include Sidekiq::Worker
  include LinkedAppsHelper
  sidekiq_options retry: 3 # TODO: Make this configurable

  @@docker_exceptions = [
    Docker::Error::ServerError,
    Docker::Error::UnauthorizedError,
    Docker::Error::ClientError,
    Docker::Error::AuthenticationError,
    Docker::Error::UnexpectedResponseError
  ]

  # Note to self: We cannot split docker build & docker push into separate workers
  # This is because if we scale out sidekiq workers in the future
  # then the build & push workers may run on different machines
  # and the push worker may not have access to the built image

  def verify_gitlab_token_validity
    linked_app = gitlab_access_token = @autobuild.gitlab_linked_app
    gitlab_access_token = linked_app.access_token

    Gitlab.endpoint = "https://gitlab.com/api/v4"
    Gitlab.private_token = gitlab_access_token

    begin
      Gitlab.user
    rescue Gitlab::Error::Unauthorized => e
      refresh_gitlab_access_token(linked_app)
    end
  end

  def build_from_branch
    # Simple case. Not a regex
    source_matches_branch = @current_rule["source"] == @ref
    source_is_a_regex = @current_rule["source"].starts_with? "/"

    if source_matches_branch
      image = build_image
    elsif source_is_a_regex
      source_regex = Regexp.new @current_rule["source"].gsub("/", "")
      if source_regex =~ @ref
        image = build_image
      end
    end

    image
  end

  def build_from_tag
    # Simple case. Not a regex
    source_matches_tag = @current_rule["source"] == @ref
    source_is_a_regex = @current_rule["source"].starts_with? "/"

    if source_matches_tag
      image = build_image
    elsif source_is_a_regex # Then this is a regex
      source_regex = Regexp.new @current_rule["source"].gsub("/", "")
      if source_regex =~ @ref
        image = build_image
      end
    end

    image
  end

  def clone_repo
    # TODO: Make the folder configurable
    repo_path = "/tmp/#{SecureRandom.hex(20)}"
    if @autobuild.code_repo_type == 'github'
      @current_build_job.update(source_repo: @current_build_job.autobuild.github_repository.http_url)

      github_access_token = @autobuild.github_linked_app.access_token
      clone_url = @autobuild.github_repository.clone_url
      clone_url_with_token = clone_url.insert(8, github_access_token + "@")
      begin
        Git.clone(clone_url_with_token, 'repo', path: repo_path, depth: 1, branch: @ref)
      rescue Git::GitExecuteError => e
        @current_build_job.update(status: 'failed')
      end

    elsif @autobuild.code_repo_type == 'gitlab'
      verify_gitlab_token_validity
      @current_build_job.update(source_repo: @current_build_job.autobuild.gitlab_repository.http_url)

      gitlab_access_token = @autobuild.gitlab_linked_app.access_token
      clone_url = @autobuild.gitlab_repository.http_url
      clone_url_with_token = clone_url.clone.insert(8, "oauth2:#{gitlab_access_token}@")

      begin
        Git.clone(clone_url_with_token, 'repo', path: repo_path, depth: 1, branch: @ref)
      rescue Git::GitExecuteError => e
        @current_build_job.update(status: 'failed')
        raise e
      end
    end

    repo_path
  end

  def docker_tag_is_valid(docker_tag)
    docker_tag_regex = /\A[\w][\w.-]{0,127}\z/
    docker_tag =~ docker_tag_regex
  end

  def get_tag_for_rule
    # TODO1: Naive implementation. Refine later
    # TODO2: move to initializer/global variable
    match_regex = /\{\\[0-9]\}{0,9}/
    source_is_a_regex = @current_rule["source"].starts_with? "/"
    rule_docker_tag = @current_rule["docker_tag"]
    docker_tag_has_sourceref = rule_docker_tag.include? "{sourceref}"

    if source_is_a_regex
      if docker_tag_has_sourceref
        docker_tag = rule_docker_tag.gsub("{sourceref}", @ref)
      elsif match_regex.match(rule_docker_tag)
        source_regex = Regexp.new @current_rule["source"].gsub("/", "")
        tag_matches = rule_docker_tag.scan(match_regex)
        source_matches = @ref.to_s.scan(source_regex).first

        tag_matches.each do |match|
          match_index = match.delete("^0-9").to_i - 1
          source_match = source_matches[match_index]

          # There has been no match for this regex match group
          next if source_match.blank?
          rule_docker_tag.gsub!(match, source_match)
        end

        docker_tag = rule_docker_tag
      end
    else
      docker_tag = @current_rule["docker_tag"]
    end

    unless docker_tag_is_valid(docker_tag)
      @current_build_job.update(status: 'failed')
      docker_tag = nil
    end

    docker_tag
  end

  def get_docker_file_path(repo_path)
    rel_dockerfile_path = @current_rule["build_context"]
    dockerfile = @current_rule["dockerfile"]
    abs_docker_file_path = Pathname.new("#{repo_path}/repo/#{rel_dockerfile_path}/#{dockerfile}").cleanpath
    dockerfile_name = SecureRandom.hex(20)
    final_dockerfile_path = "#{repo_path}/#{dockerfile_name}"

    FileUtils.cp(
      abs_docker_file_path,
      final_dockerfile_path
    )

    final_dockerfile_path
  end

  def build_image
    repo_path = clone_repo

    parser = Yajl::Parser.new
    dockerfile = @current_rule["dockerfile"]
    rel_dockerfile_path = @current_rule["build_context"]
    abs_docker_file_path = get_docker_file_path(repo_path)
    temp_docker_tag = SecureRandom.hex(10)

    log_file_path = "#{repo_path}/#{SecureRandom.hex(20)}"
    log_file = File.new(log_file_path, "w")
    begin
      image = Docker::Image.build_from_dir(
        "#{repo_path}/repo/#{rel_dockerfile_path}",
        t: temp_docker_tag,
        dockerfile: dockerfile,
        buildargs: @autobuild.env_vars.map { |x| { x["key"] => x["value"] } unless x["key"].empty? }.inject(:merge).to_h
      ) do |line|
          parser.parse(line) do |x|
            log_line = x.fetch("stream", "")
            log_file.puts log_line
          end
        end
    rescue *@@docker_exceptions => e
      @current_build_job.update(status: 'failed')
      raise e
    ensure
      log_file.close
      @current_build_job.update(
        build_logs_path: log_file_path,
        dockerfile_path: abs_docker_file_path
      )
    end

    image
  end

  def push_image(image)
    docker_tag = get_tag_for_rule

    # This means the tag is invalid
    # Skip this push
    return if docker_tag.blank?
    return unless @current_rule["autobuild"]

    @current_build_job.update(status: 'pushing')
    docker_registry = @autobuild.docker_hub_registries.first
    repo_name = "#{docker_registry.username}/#{docker_registry.repo_name}"

    begin
      Docker.authenticate!(username: docker_registry.username, password: docker_registry.access_token)
      image.tag(
        repo: repo_name,
        tag: docker_tag
      )
      image.push
    rescue *@@docker_exceptions => e
      @current_build_job.update(status: 'failed')
      raise e
    end

    @current_build_job.update(image_uri: image.info.dig("RepoTags").first)
  end

  def get_commit_sha
    @payload.dig("after").to_s
  end

  def perform(autobuild_id, webhook_payload)
    @autobuild = Autobuild.find(autobuild_id)
    @payload = JSON.parse webhook_payload

    hook_for_tag = @payload["ref"].split("/")[1] == "tags"
    hook_for_branch = @payload["ref"].split("/")[1] == "heads"

    # @payload["ref"] is of the format "refs/tags/v1.0.0" or "refs/heads/master"
    @ref = @payload["ref"].split("/")[-1]
    @autobuild.rules.each do |rule|
      @current_rule = rule
      start_time = Time.now
      docker_tag = get_tag_for_rule

      if @current_rule["source_type"] == "branch" and hook_for_branch
        @current_build_job = @autobuild.build_jobs.create(
          status: 'queued',
          docker_tag: docker_tag,
          commit_sha: get_commit_sha,
          matched_rule: rule
        )
        image = build_from_branch
      elsif @current_rule["source_type"] == "tag" and hook_for_tag
        @current_build_job = @autobuild.build_jobs.create(
          status: 'queued',
          docker_tag: docker_tag,
          commit_sha: get_commit_sha,
          matched_rule: rule
        )
        image = build_from_tag
      else
        next
      end

      # None of the rules match
      next if image.blank?
      push_image(image)

      end_time = Time.now
      image_with_info = Docker::Image.get(image.id)
      @current_build_job.update({
        complete: true,
        status: 'complete',
        duration: (end_time - start_time).to_i,
        image_size: image_with_info.info["Size"].to_i
      })
    end
  end
end
