execute "apt-get update -q -y" do
  environment ({ "DEBIAN_FRONTEND" => "noninteractive" })
  action :run
end
