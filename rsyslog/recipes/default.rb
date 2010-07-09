#
# Cookbook Name:: rsyslog
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "rsyslog" do
  action :install
end

service "rsyslog" do
  supports :restart => true, :reload => true
  action [:enable, :start]
end

cookbook_file "/etc/default/rsyslog" do
  source "rsyslog.default"
  owner "root"
  group "root"
  mode 0644
end

directory "/etc/rsyslog.d" do
  owner "root"
  group "root"
  mode 0755
end

template "/etc/rsyslog.conf" do
  source "rsyslog.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "rsyslog"), :delayed
end

directory node[:rsyslog][:log_dir] do
  owner "syslog"
  group "adm"
  mode 0755
end

template "/etc/rsyslog.d/50-default.conf" do
  source "50-default.conf.erb"
  backup false
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "rsyslog"), :delayed
end

node[:rsyslog][:conf].each do |name, conf|
  template "/etc/rsyslog.d/10-#{name}.conf" do
    source "webapp.conf.erb"
    backup false
    owner "root"
    group "root"
    mode 0644
    variables(
        :app => name,
        :facility => conf[:facility],
        :log_dir => node[:rsyslog][:log_dir]
    )
    notifies :restart, resources(:service => "rsyslog"), :delayed
  end
end
