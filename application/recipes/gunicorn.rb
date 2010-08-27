#
# Cookbook Name:: application
# Recipe:: gunicorn 
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

include_recipe "gunicorn"
include_recipe "nginx"

template "#{node[:nginx][:dir]}/sites-available/#{app[:id]}.conf" do
  source "django_nginx_gunicorn.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :app => app[:id],
    :docroot => File.join(app[:deploy_to], "current", "media"),
    :server_name => "#{app[:id]}.#{node[:domain]}",
    :server_aliases => [ node[:fqdn], app[:id] ] + app[:aliases]
  )
end

nginx_site "#{app[:id]}.conf" do
  notifies :restart, resources(:service => "nginx")
end

node.default[:gunicorn][:worker_processes] = [node[:cpu][:total].to_i * 4, 8].min
node.default[:unicorn][:preload_app] = true

gunicorn_config "/etc/gunicorn/#{app[:id]}.py" do
  bind "unix:/var/run/#{app[:id]}-unicorn.sock"
  worker_processes node[:gunicorn][:worker_processes]
  preload_app node[:gunicorn][:preload_app] 
end

runit_service app[:id] do
  template_name 'gunicorn'
  cookbook 'application'
  options(:app => app)
  run_restart false
end

if File.exists?(File.join(app['deploy_to'], "current"))
  d = resources(:deploy => app[:id])
  d.restart_command do
    service "nginx" do action :restart; end
    execute "/etc/init.d/#{app[:id]} hup"
  end
end
