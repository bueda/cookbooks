include_recipe "s3"
require "aws/s3"

AWS::S3::Base.establish_connection!(
    :access_key_id     => node[:s3][:access_key_id],
    :secret_access_key => node[:s3][:secret_access_key]
)

node[:s3][:files].each do |name, config|
  directory config[:directory] do
    owner config[:owner]
    group config[:group]
    mode "0664"
    recursive true
  end

  open(config[:directory] + "/" + name, "w") do |file|
    obj = AWS::S3::S3Object.find config[:name], config[:bucket]
    file.write obj.value
  end unless File.exists?(config[:directory] + "/" + name)
end
