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

include_recipe "nginx"
include_recipe "gunicorn::system"

nginx_site "default" do
  enable false
end

if app[:ssl]
  cookbook_file "/etc/ssl/certs/#{app[:ssl][:certificate][:file]}" do
    source app[:ssl][:certificate][:file]
    cookbook app[:ssl][:certificate][:cookbook]
    mode 0644
  end
  cookbook_file "/etc/ssl/private/#{app[:ssl][:key][:file]}" do
    source app[:ssl][:key][:file]
    cookbook app[:ssl][:key][:cookbook]
    mode 0644
  end
end

nginx_site "#{app[:id]}.conf" do
  notifies :restart, resources(:service => "nginx")
end

node.default[:gunicorn][:worker_processes] = [node[:cpu][:total].to_i * 4, 8].min
node.default[:unicorn][:preload_app] = true

gunicorn_config "/etc/gunicorn/#{app[:id]}.py" do
  bind "unix:/var/run/gunicorn/#{app[:id]}.sock"
  worker_processes node[:gunicorn][:worker_processes]
  preload_app node[:gunicorn][:preload_app] 
end
