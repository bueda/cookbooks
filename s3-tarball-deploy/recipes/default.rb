include_recipe "s3"
require "aws/s3"

AWS::S3::Base.establish_connection!(
    :access_key_id     => node[:s3][:access_key_id],
    :secret_access_key => node[:s3][:secret_access_key]
)

node[:s3_tarball_deploy].each do |name, config|
  open("/tmp/#{config[:file]}", "w") do |file|
    obj = AWS::S3::S3Object.find config[:file], config[:bucket]
    file.write obj.value
  end unless File.exists?("/tmp/#{config[:file]}")

  directory config[:deploy_parent] + "/releases" do
    owner "deploy"
    group "bueda"
    mode "0775"
    recursive true
  end

  directory config[:deploy_parent] + "/packages" do
    owner "deploy"
    group "bueda"
    mode "0775"
    recursive true
  end

  bash "deploy" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    tar -xzf #{config[:file]}
    mv #{config[:file]} #{config[:deploy_parent]}/packages/
    mv /tmp/#{config[:extracted_folder]} #{config[:deploy_parent]}/releases/#{config[:deploy_target]}
    chown #{config[:owner]}:#{config[:group]} -R #{config[:deploy_parent]}/releases/#{config[:deploy_target]}
    chmod 775 -R #{config[:deploy_parent]}/releases/#{config[:deploy_target]}
    EOH
    not_if do File.exists?(config[:deploy_parent] + "/releases/" + config[:deploy_target]) end
  end

  link config[:deploy_parent] + "/releases/" + config[:symlink] do
    to config[:deploy_parent] + "/releases/" + config[:deploy_target]
    notifies :start, resources(:service => "apache2")
  end

  file "/tmp/#{config[:file]}" do 
    action :delete
  end
end
