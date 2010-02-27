include_recipe "s3"
require "aws/s3"
require 'resource/pip_package.rb'

AWS::S3::Base.establish_connection!(
    :access_key_id     => node[:s3][:access_key_id],
    :secret_access_key => node[:s3][:secret_access_key]
)

node[:buedapy][:virtualenvs].each do |env|
  if not File.exists?(env + "/lib/python2.6/site-packages/language_model") then
    open("/tmp/buedapy.tar.gz", "w") do |file|
      obj = AWS::S3::S3Object.find "buedapy.tar.gz", "bueda.deploy"
      file.write obj.value
    end unless File.exists?("/tmp/buedapy.tar.gz")

    pip_package "buedapy" do
      action :install_from_file
      source "/tmp/buedapy.tar.gz"
      virtualenv env
      only_if do File.exists?("/tmp/buedapy.tar.gz") end
    end

    file "/tmp/buedapy.tar.gz" do 
      action :delete
    end
  end
end
