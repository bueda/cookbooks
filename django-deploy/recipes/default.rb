require "aws/s3"

AWS::S3::Base.establish_connection!(
    :access_key_id     => node[:s3][:access_key_id],
    :secret_access_key => node[:s3][:secret_access_key]
)

open("/tmp/django-app.tar.gz", "w") do |file|
  S3Object.stream "django-app.tar.gz", "bueda.deploy" do |chunk|
    file.write chunk
  end
end unless File.exists?("/tmp/django-app.tar.gz")

bash "deploy_django" do
  user "deploy"
  cwd "/tmp"
  code <<-EOH
  tar -xzf django-app.tar.gz
  mv django-app /var/django/bootstrap
  ln -s /var/django/bootstrap /var/django/current
  EOH
  not_if do File.exists?("/var/django/bootstrap")
  notifies :restart, resource(:service => "apache)
end
