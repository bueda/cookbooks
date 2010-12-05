#
# Cookbook Name:: mongodb
# Recipe:: default
#
# Copyright 2010, Bueda Inc.
#
# All rights reserved - Do Not Redistribute
#

bash "add apt repository for mongodb" do
  code "apt-add-repository 'deb http://downloads.mongodb.org/distros/ubuntu #{node[:platform_version]} 10gen' && apt-get update"
end
