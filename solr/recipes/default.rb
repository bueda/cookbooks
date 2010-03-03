#
# Cookbook Name:: solr
# Recipe:: default
#

require 'digest/sha1'

directory "/var/log/solr" do
  owner "solr"
  group "bueda"
  mode 0755
  recursive true
end

#TODO register this as a service
remote_file "/etc/init.d/jetty" do
  source "jetty.sh"
  owner "root"
  group "root"
  mode 0755
end

template "/etc/default/jetty" do
  source "jetty.erb"
  owner "root"
  group "root"
  mode 0755
  variables({
    :config => node[:solr]
  })
end

execute "install solr example package" do
  command("if [ ! -e /data/#{app}/jettyapps/solr ]; then cd /data/#{app}/jettyapps && " +
          "wget -O apache-solr-1.3.0.tgz http://mirror.cc.columbia.edu/pub/software/apache/lucene/solr/1.3.0/apache-solr-1.3.0.tgz && " +
          "tar -xzf apache-solr-1.3.0.tgz && " +
          "mv apache-solr-1.3.0/example solr && " + 
          "rm -rf apache-solr-1.3.0; fi")
  action :run
end

remote_file "#{node[:solr][:home]}/etc/jetty-logging.xml" do
  source "jetty-logging.xml"
  owner "solr"
  group "bueda"
  mode 0755
end

#TODO how will we change this for different data sources?
remote_file "#{node[:solr][:home]}/solr/conf/schema.xml" do
  source node[:solr][:schema]
  owner "solr"
  group "bueda"
  mode 0755
end
