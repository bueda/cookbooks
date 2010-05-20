gem = gem_package "aws-s3" do
  action :nothing
end
gem.run_action :install

require 'rubygems'
Gem.clear_paths
require 'aws-s3'
