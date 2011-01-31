#
# Cookbook Name:: application
# Recipe:: tornado 
#
# Copyright 2010, Bueda, Inc.
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

app = node.run_state[:current_app] 

include_recipe "nginx"
include_recipe "tornado"

app[:tornado_port] ||= 8888
app[:log_file_prefix] = "/var/log/tornado/#{app[:id]}"
app[:logging] = "info"

template "#{node[:nginx][:dir]}/sites-available/#{app[:id]}.conf" do
  source "tornado_nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :app => app[:id],
    :ssl => app[:ssl],
    :port => app[:port] || 80,
    :tornado_port => app[:tornado_port],
    :docroot => File.join(app[:deploy_to], "current"),
    :virtualenv => app[:virtualenv],
    :server_name => "#{app[:id]}.#{node[:domain]}",
    :server_aliases => [ app[:id] ] + (app[:aliases] || [])
  )
  notifies :restart, resources(:service => "nginx")
end

runit_service app[:id] do
  template_name 'tornado'
  cookbook 'application'
  options(:app => app, :runner => app[:runner])
  run_restart false
end

nginx_site "#{app[:id]}.conf" do
  notifies :restart, resources(:service => "nginx")
  enable true
end

tornado_config "/etc/tornado/#{app[:id]}.py" do
  port app[:tornado_port]
  log_file_prefix app[:log_file_prefix]
  logging app[:logging]
end
