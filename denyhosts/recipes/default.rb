package "denyhosts" do
  action :install
end

service "denyhosts" do
  supports :restart => true
  action [ :enable, :start ]
end

remote_file "/etc/hosts.allow" do
  source "hosts.allow"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "denyhosts")
end

service "denyhosts" do
  action :start
end
