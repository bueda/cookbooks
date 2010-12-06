#
# Cookbook Name:: mongodb
# Recipe:: default
#
# Copyright 2010, Bueda Inc.
#
# All rights reserved - Do Not Redistribute
#


bash "apt-get update" do
  code "apt-get update"
  action :nothing
end

bash "add 10gen key" do
  code "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
  action :nothing
  notifies :run, resources(:bash => "apt-get update"), :immediately
end

template "/etc/apt/sources.list.d/10gen.list" do
  source "10gen.list.erb"
  mode 0644
  notifies :run, resources(:bash => "add 10gen key"), :immediately
end

template node[:mongodb][:config] do
  source "mongodb.conf.erb"
  owner "mongodb"
  group "mongodb"
  mode 0644
  backup false
end

service "mongodb" do
  supports :start => true, :stop => true, "force-stop" => true, :restart => true, "force-reload" => true, :status => true
  action [:enable, :start]
  subscribes :restart, resources(:template => node[:mongodb][:config])
end
