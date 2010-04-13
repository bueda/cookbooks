package "vim-gnome"
package "ack-grep"
package "htop"

bash "ln -fs /bin/bash /bin/sh"

node[:sysadmin][:files].each do |file|
  remote_file "/usr/local/bin/#{file}" do
    source "sysadmin/#{file}"
    mode 0755
  end
end if node[:sysadmin] and node[:sysadmin][:files]
