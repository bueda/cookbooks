#
# Cookbook Name:: irstlm
# Recipe:: default
#
# Copyright 2010, Bueda Inc.
#
# All rights reserved - Do Not Redistribute
#

package "zlib1g-dev"

deb_file = "/tmp/irstlm.deb"

if node[:kernel][:machine].eql?("x86_64")
  cookbook_file deb_file do
    source "irstlm_5.30-1_amd64.deb"
  end
else
  cookbook_file deb_file do
    source "irstlm_5.30-1_i386.deb"
  end
end

dpkg_package "irstlm" do
  source deb_file
end
