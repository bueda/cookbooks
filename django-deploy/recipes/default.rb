require 'aws/s3'

AWS::S3::Base.establish_connection!(
    :access_key_id     => node[:s3][:access_key_id],
    :secret_access_key => node[:s3][:secret_access_key]
)

open('/tmp/django-app.tar.gz', 'w') do |file|
  S3Object.stream 'django-app.tar.gz', 'bueda.deploy' do |chunk|
    file.write chunk
  end
end

node[:django_deploy].each do |path, config|
  deploy path do
    repo config[:repo]
    revision config[:revision]
    user "deploy"
    group "bueda"
    migrate false
    shallow_clone true
    restart_command "touch #{config[:wsgi_script]}"
    action :deploy
  end
end
