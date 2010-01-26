execute "apt-get update" do
  environment { "DEBIAN_FRONTEND" => "noninteractive" }
  action :run
end

execute "apt-get dist-upgrade -q -y" do
  environment { "DEBIAN_FRONTEND" => "noninteractive" }
  action :run
end
