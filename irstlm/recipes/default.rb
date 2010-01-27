remote_file "/tmp/irstlm.tar.gz" do
  source "http://downloads.sourceforge.net/project/irstlm/irstlm/irstlm-5.22.01/irstlm-5.22.01.tar.gz"
end

directory "/tmp/irstlm/src" do
    owner "root"
    group "root"
    mode "0775"
    action :create
    recursive true
    not_if "test -d /tmp/irstlm"
end

remote_file "/tmp/irstlm/SConstruct" do
    source "SConstruct"
end

bash "install_irstlm" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  tar -xzf irstlm.tar.gz -C irstlm
  cd irstlm/src
  scons
  mkdir -p /usr/local/include/irstlm
  cp *.h /usr/local/include/irstlm
  cp libirstlm.so /usr/local/lib
  #rm -rf /tmp/irstlm*
  EOH
end
