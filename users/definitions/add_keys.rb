define :add_keys do
  config = params[:conf]
  name = params[:name]
  keys = Mash.new
  keys[name] = node[:ssh_keys][name]

  if config[:extra_ssh_keys]
    config[:extra_ssh_keys].each do |username|
      keys[username] = node[:ssh_keys][username]
    end
  end
  
  template "/home/#{name}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    action :create
    owner name
    group config[:gid]
    variables(:keys => keys)
    mode 0600
    not_if { defined?(node[:users][name][:preserve_keys]) ? node[:users][name][:preserve_keys] : false }
  end
end
