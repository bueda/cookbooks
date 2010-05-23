#
# Cookbook Name:: mysql-database
# Recipe:: default
#
# Copyright 2010, Opscode, Inc.
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

include_recipe "mysql::server"

node[:mysql][:databases].each do |db|
  bash "create db #{db}" do
    code "echo 'CREATE DATABASE #{db};' > mysql -u root -p#{node[:mysql][:server_root_password]}"
  end
end if node[:mysql] and node[:mysql][:databases]
