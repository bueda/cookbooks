#
# Cookbook Name:: apache2-bueda
# Recipe:: default
#
# Copyright 2010, Bueda Inc.
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
# See the License for the specific language governing permissions and # limitations under the License.
#

include_recipe 'apache2'
include_recipe "apache2::mod_wsgi"

# Disable default site
apache_site "default" do
  action :disable
end

node[:apache][:web_apps].each do |name, config|
    web_app name do
      config.each do |k,v|
        send(k.to_sym, v)
      end
    end
end if node[:apache] and node[:apache][:web_apps]

remote_file "/usr/local/bin/apache2_syslog.pl" do
  source "apache2_syslog.pl"
  mode "0755"
end
