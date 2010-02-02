require "aws/s3"

AWS::S3::Base.establish_connection!(
    :access_key_id     => node[:s3][:access_key_id],
    :secret_access_key => node[:s3][:secret_access_key]
)

open("/tmp/buedapy.tar.gz", "w") do |file|
  S3Object.stream "buedapy.tar.gz", "bueda.deploy" do |chunk|
    file.write chunk
  end
end

pip_package "buedapy" do
  action :install_from_file
  source "/tmp/buedapy.tar.gz"
  virtualenv node[:buedapy][:virtualenv]
end
