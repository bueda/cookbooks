packages = case node[:platform]
  when "centos","redhat","fedora"
    %w{openssh-clients openssh}
  else
    %w{openssh-client openssh-server}
  end
  
packages.each do |pkg|
  package pkg
end

service "ssh" do
  case node[:platform]
  when "centos","redhat","fedora"
    service_name "sshd"
  else
    service_name "ssh"
  end
  supports :restart => true
  action [ :enable, :start ]
end

remote_file "/etc/ssh/known_hosts" do
  source "known_hosts"
  mode 0644
end

template "/etc/ssh/sshd_config" do
  source "sshd_config.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "ssh")
end

service "ssh" do
  action :restart
end
