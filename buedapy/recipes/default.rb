include_recipe "s3"
require "aws/s3"
require 'resource/pip_package.rb'

p = package "swig" do
  action :nothing
end
p.run_action :install

AWS::S3::Base.establish_connection!(
    :access_key_id     => node[:s3][:access_key_id],
    :secret_access_key => node[:s3][:secret_access_key]
)

if not File.exists?(node[:buedapy][:virtualenv] \
        + "/lib/python2.6/site-packages/language_model") then
  open("/tmp/buedapy.tar.gz", "w") do |file|
    obj = AWS::S3::S3Object.find "buedapy.tar.gz", "bueda.deploy"
    file.write obj.value
  end unless File.exists?("/tmp/buedapy.tar.gz")

  pip_package "buedapy" do
    action :install_from_file
    source "/tmp/buedapy.tar.gz"
    virtualenv node[:buedapy][:virtualenv]
    only_if do File.exists?("/tmp/buedapy.tar.gz") end
  end

  file "/tmp/buedapy.tar.gz" do 
    action :delete
  end
end
