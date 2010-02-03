package "vim-gnome"
package "ack-grep"
package "htop"

#TODO media site for nginx?
#TODO switch from EBS to ephemeral - grab from dev server with rsync or from S3
#TODO deploy django 

node[:sysadmin][:files].each do |file|
  remote_file "/usr/local/bin/#{file}" do
    source "sysadmin/#{file}"
    mode 0755
  end
end if node[:sysadmin] and node[:sysadmin][:files]

directory "/var/log/bueda" do
  owner "www-data"
  group "bueda"
  mode "0775"
  action :create
  not_if "test -d /var/log/bueda"
end
