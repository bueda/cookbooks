package "libshadow-ruby1.8" do
  action :install
end

node[:groups].each do |group_key, config|
  group group_key do
    group_name group_key.to_s
    gid config[:gid]
    action [:create, :manage]
  end
end unless not node[:groups]

node[:users].each do |username, config|
  user username do
    comment config[:comment]
    uid config[:uid]
    gid config[:gid]
    home (config[:home] ? config[:home] : "/home/#{username}")
    shell (config[:shell] ? config[:shell] : "/bin/bash")
    password config[:password]
    supports :manage_home => true
    action [:create, :manage]
  end  

  config[:files].each do |filename|
    remote_file "/home/#{username}/#{filename}" do
      source "#{username}/#{filename}"
      mode 0750
      owner username
      group config[:gid]
    end
  end unless not config[:files]
  
  directory "/home/#{username}/.ssh" do
    action :create
    owner username
    group config[:gid]
    mode 0700
  end
  
  add_keys username do
    conf config
  end if config[:ssh_keys]

  config[:groups].each do |g|
    group g do
      members [ username ]
      append true
      action [:modify]
    end
  end if config[:groups]
end unless not node[:users]
