package "vim-gnome"
package "ack-grep"
package "htop"
package "runurl" 
package "ec2-init"

#TODO method to do a dist-upgrade?
#TODO pip provider with option for a virtualenv
#TODO add repository?
#TODO media site for nginx?
#TODO irstlm
#TODO denyhosts whitelist template
#TODO switch from EBS to ephemeral - grab from dev server with rsync or from S3
#TODO switch apache, django and mail logs to empemeral storage
#TODO deploy django 
#TODO email start/stop scripts

node[:sysadmin][:files].each do |file|
  remote_file "/usr/local/bin/#{file}" do
    source "sysadmin/#{file}"
    mode 0755
  end
end
