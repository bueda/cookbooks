package "vim-gnome"
package "ack-grep"
package "htop"
package "runurl" 
package "ec2-init"

#TODO media site for nginx?
#TODO irstlm
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
