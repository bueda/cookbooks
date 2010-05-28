#
# Cookbook Name:: 4store
# Recipe:: default
#
# Copyright 2010, Bueda Inc.
#
# All rights reserved - Do Not Redistribute
#

%w{libraptor1-dev
    librasqal2-dev
    libpcre3-dev
    libncurses-dev
    libreadline-dev
    libglib2.0-dev}.each do |pkg|
  package pkg
end

deb_file = "/tmp/4store-1.0.3.deb"

if node[:kernel][:machine].eql?("x86_64")
  remote_file deb_file do
    source "4store_v1.0.3-1_amd64.deb"
  end
else
  remote_file deb_file do
    source "4store_v1.0.3-1_i386.deb"
  end
end

dpkg_package "4store" do
  source deb_file
end
