include_recipe "apt"

package "vim-gnome"
package "ack-grep"
package "htop"
package "rake"

gem_package "chef" do
  version node[:chef][:client_version]
end

bash "switch sh to bash" do
  code "ln -fs /bin/bash /bin/sh"
  not_if do File.readlink("/bin/sh").eql? "/bin/bash" end
end

node[:sysadmin][:files].each do |file|
  remote_file "/usr/local/bin/#{file}" do
    source "sysadmin/#{file}"
    mode 0755
  end
end if node[:sysadmin] and node[:sysadmin][:files]
