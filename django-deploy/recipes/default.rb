include_recipe "s3"
require "aws/s3"

AWS::S3::Base.establish_connection!(
    :access_key_id     => node[:s3][:access_key_id],
    :secret_access_key => node[:s3][:secret_access_key]
)

open("/tmp/django-app.tar.gz", "w") do |file|
  obj = AWS::S3::S3Object.find "django-app.tar.gz", "bueda.deploy"
  file.write obj.value
end unless File.exists?("/tmp/django-app.tar.gz")

bash "deploy_django" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  tar -xzf django-app.tar.gz
  mv django-app /var/django/bootstrap
  chown deploy:bueda -R /var/django/bootstrap
  ln -s /var/django/bootstrap /var/django/bueda
  EOH
  not_if do File.exists?("/var/django/bootstrap") end
  notifies :restart, resources(:service => "apache2")
end
