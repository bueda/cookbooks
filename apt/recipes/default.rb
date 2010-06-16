execute "apt-get update -q -y" do
  environment ({ "DEBIAN_FRONTEND" => "noninteractive" })
  action :run
end

execute "apt-get upgrade -q -y" do
  environment ({ "DEBIAN_FRONTEND" => "noninteractive" })
  action :run
end
