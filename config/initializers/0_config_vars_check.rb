[
  'GITHUB_OAUTH_CLIENT_ID',
  'GITLAB_OAUTH_CLIENT_ID',
  'GITLAB_OAUTH_REDIRECT_URL',
  'GITLAB_OAUTH_CLIENT_SECRET',
  'GITLAB_OAUTH_REDIRECT_URL',
  'GITHUB_OAUTH_CLIENT_ID',
  'GITHUB_OAUTH_CLIENT_SECRET',
  'DOMAIN_NAME',
  'REDIS_URL',
  'DATABASE_URL'
].each do |env_var|
  raise StandardError.new "#{env_var} environment variable not set!" if ENV[env_var].blank?
end

if Rails.env.production?
  [
    'SMTP_USERNAME',
    'SMTP_PASSWORD',
    'SMTP_PORT',
    'SMTP_DOMAIN',
    'SMTP_ADDRESS'
  ].each do |env_var|
    raise StandardError.new "#{env_var} environment variable not set!" if ENV[env_var].blank?
  end
end