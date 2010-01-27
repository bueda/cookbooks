execute "apt-get update -q -y" do
  #TODO
  #environment { "DEBIAN_FRONTEND" => "noninteractive" }
  action :run
end

execute "apt-get dist-upgrade -q -y" do
  #TODO
  #environment { "DEBIAN_FRONTEND" => "noninteractive" }
  action :run
end
