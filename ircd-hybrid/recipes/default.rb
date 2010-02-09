package "ircd-hybrid"

service "ircd-hybrid" do
  supports :restart => true
  action [ :enable, :start ]
end

remote_file "/etc/ircd-hybrid/ircd.motd" do
  source "ircd.motd"
  mode 0644
end

template "/etc/ircd-hybrid/ircd.conf" do
  source "ircd.conf.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "ircd-hybrid")
end

service "ircd-hybrid" do
  action :restart
end
