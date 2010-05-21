package "zlib1g-dev"

deb_file = "/tmp/irstlm.deb"

remote_file deb_file do
  source "irstlm_5.30-1_i386.deb"
end

dpkg_package "irstlm" do
  source deb_file
end

file deb_file do
  action :nothing
  subscribes :delete, resources(:remote_file => deb_file)
end
