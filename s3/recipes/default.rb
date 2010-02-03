p = gem_package "aws-s3" do
  action :nothing
end
p.run_action :install
Gem.clear_paths
