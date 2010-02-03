define :add_keys do
  name = params[:name]
  config = params[:conf]
  keys = config[:ssh_keys]

  template "/home/#{name}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    action :create
    owner name
    group config[:gid]
    variables(:keys => keys)
    mode 0600
    not_if { defined?(node[:users][name][:preserve_keys]) ? node[:users][name][:preserve_keys] : false }
  end
end if keys
