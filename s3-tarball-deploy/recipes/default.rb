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

  bash "deploy" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    tar -xzf #{config[:file]}
    EOH
    not_if do File.exists?(config[:deploy_parent] + config[:deploy_target]) end
  end

  remote_directory config[:deploy_parent] + config[:deploy_target] do
    source "/tmp/" + config[:extracted_folder]
    owner config[:owner]
    group config[:group]
  end

  link config[:symlink] do
    to config[:deploy_parent] + config[:deploy_target]
    notifies :restart, resources(:service => "apache2")
  end
end
