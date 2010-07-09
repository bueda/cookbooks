require_recipe "unicorn"

gem_package "tinder"
gem_package "cijoe"

directory "/etc/cijoe" do
  owner node[:cijoe][:user]
  group node[:cijoe][:group]
end

directory node[:cijoe][:build_root] do
  owner node[:cijoe][:user]
  group node[:cijoe][:group]
  recursive true
end

repos = []

search(:repos, "*:*") do |repo|
  next unless repo[:ci]
  name = repo[:user] + "/" + repo[:id]
  repo[:ci].each do |branch|
    
    full_name = "#{name}-#{branch}"
    full_path = "#{node[:cijoe][:build_root]}/#{full_name}"
    repos << {:full_name => full_name, :full_path => full_path}

    cookbook_file "/usr/local/bin/unsafe-ssh" do
      source "unsafe-ssh"
      mode "0755"
    end

    template "/#{node[:cijoe][:build_root]}/#{repo[:id]}.id_rsa" do
      source "id_rsa.erb"
      variables :key => repo[:key][:private]
      owner node[:cijoe][:user]
      mode 0600
    end

    execute "start ssh-agent" do
      user node[:cijoe][:user]
      command "ssh-agent -a /tmp/agent.pid &"
    end

    execute "add ssh key for #{full_name} to ssh agent" do 
      user node[:cijoe][:user]
      cwd node[:cijoe][:build_root]
      environment "SSH_AUTH_SOCK" => "/tmp/agent.pid"
      command "ssh-add #{repo[:id]}.id_rsa"
      not_if "SSH_AUTH_SOCK=/tmp/agent.pid ssh-add -l | grep #{repo[:id]}.id_rsa"
    end

    git full_path do
      user node[:cijoe][:user]
      repository "#{node[:cijoe][:git_url_prefix]}:#{name}.git"
      reference "HEAD"
      action :sync
      ssh_wrapper "/usr/local/bin/unsafe-ssh"
      not_if { File.directory?(full_path) }
    end

    execute "cijoe set active branch for #{full_name}" do
      user node[:cijoe][:user]
      cwd full_path
      command "git config --add cijoe.branch #{branch}"
      not_if "grep 'branch = #{branch}' #{full_path}/.git/config"
    end

    cookbook_file "#{full_path}/.git/hooks/after-reset" do
      source "after-reset"
      mode "0755"
    end

    execute "cijoe setup campfire for #{full_name}" do
      user node[:cijoe][:user]
      cwd full_path
      command "git config --add campfire.user #{node[:ci][:campfire_token]} &&
               git config --add campfire.pass x &&
               git config --add campfire.subdomain #{node[:ci][:campfire_subdomain]} &&
               git config --add campfire.room #{node[:ci][:campfire_room]} &&
               git config --add campfire.ssl true"
      not_if "grep campfire #{node[:ci][:campfire_room]}/.git/config"
    end

    execute "cijoe setup test runner for #{full_name}" do
      cmd = node[:cijoe][:runner]
      user node[:cijoe][:user]
      cwd full_path
      command "git config --add cijoe.runner \"#{cmd}\""
      not_if "grep '#{cmd}' #{full_path}/.git/config"
    end
  end
end

template "/etc/cijoe/config.ru" do
  variables :repos => repos
  mode 0644
end
template "/etc/cijoe/unicorn.conf.rb" do
  source "unicorn.conf.erb"
end
