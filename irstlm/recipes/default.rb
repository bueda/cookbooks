package "zlib1g-dev"

remote_file "/tmp/irstlm.deb" do
  source "irstlm_5.30-1_i386.deb"
end

dpkg_package "irstlm" do
  source "/tmp/irstlm.deb"
end
