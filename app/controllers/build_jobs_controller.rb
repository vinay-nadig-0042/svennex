class BuildJobsController < ApplicationController
  def index
    @build_jobs = current_user.build_jobs.paginate(page: params[:page], per_page: 10)
    @build_job_count = current_user.build_jobs.count
  end

  def dockerfile
    @build_job = current_user.build_jobs.find(params[:id])
    if @build_job.dockerfile_path
      @dockerfile_contents = File.read(@build_job.dockerfile_path)
    else
      @dockerfile_contents = "Dockerfile Unavailable"
    end
  end

  def logs
    @build_job = current_user.build_jobs.find(params[:id])
    if @build_job.build_logs_path
      @build_logs = File.read(@build_job.build_logs_path)
    else
      @build_logs = "Build Logs Unavailable"
    end
  end
end