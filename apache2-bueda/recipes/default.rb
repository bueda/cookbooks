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
include_recipe "apache2-bueda::mod_wsgi"
include_recipe "apache2::mod_ssl"

# Disable default site
apache_site "000-default" do
  action :disable
end

node[:apache][:web_apps].each do |name, config|
  if config[:port]
    # Unsecured version of the template - strip out SSL info in case
    # this webapp has both secure and unsecure.
    web_app name do
      config.each do |k,v|
        send(k.to_sym, v) unless k.eql? "ssl"
      end
    end
    template "/usr/local/bin/apache2_syslog-#{name}.pl" do
      source "apache2_syslog.pl.erb"
      mode "0755"
      variables :tag => name,
          :facility => node[:apache][:log_facility],
          :level => node[:apache][:log_level]
      #notifies :restart, resources(:service => "apache2"), :delayed
    end
  end
  if config[:ssl]
    # Secured version of the template
    [:certificate, :key, :chain].each do |cert_file|
      cookbook_file "/etc/apache2/ssl/#{config[:ssl][cert_file]}" do
        source config[:ssl][cert_file]
        mode 0644
      end
    end
    config[:hostname] = name
    name = name += "_ssl"
    config[:wsgi_name] += "_ssl"
    web_app name do
      config.each do |k,v|
        send(k.to_sym, v)
      end
    end
    template "/usr/local/bin/apache2_syslog-#{name}.pl" do
      source "apache2_syslog.pl.erb"
      mode "0755"
      variables :tag => name,
          :facility => node[:apache][:log_facility],
          :level => node[:apache][:log_level]
      #notifies :restart, resources(:service => "apache2"), :delayed
    end
  end
end if node[:apache] and node[:apache][:web_apps]
