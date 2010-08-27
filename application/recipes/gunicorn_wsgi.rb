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

include_recipe "application::gunicorn"

template "#{node[:nginx][:dir]}/sites-available/#{app[:id]}.conf" do
  source "wsgi_nginx_gunicorn.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :app => app[:id],
    :ssl => app[:ssl],
    :port => app[:port] || 80,
    :docroot => File.join(app[:deploy_to], "current"),
    :virtualenv => app[:virtualenv],
    :server_name => "#{app[:id]}.#{node[:domain]}",
    :server_aliases => [ node[:fqdn], app[:id] ] + (app[:aliases] || [])
  )
end

runit_service app[:id] do
  template_name 'gunicorn'
  cookbook 'application'
  options(:app => app, :gunicorn_binary => "gunicorn")
  run_restart false
end
