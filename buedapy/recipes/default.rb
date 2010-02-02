p = gem_package "aws-s3"
p.run_action(:install)

Gem.clear_paths
require "aws/s3"

AWS::S3::Base.establish_connection!(
    :access_key_id     => node[:s3][:access_key_id],
    :secret_access_key => node[:s3][:secret_access_key]
)

open("/tmp/buedapy.tar.gz", "w") do |file|
  obj = AWS::S3::S3Object.find "buedapy.tar.gz", "bueda.deploy"
  file.write obj.value
end unless File.exists?("/tmp/buedapy.tar.gz")

pip_package "buedapy" do
  action :install_from_file
  source "/tmp/buedapy.tar.gz"
  virtualenv node[:buedapy][:virtualenv]
  only_if File.exists?("/tmp/buedapy.tar.gz")
end
