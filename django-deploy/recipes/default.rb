require 'chef-deploy'

["deploy_key", "deploy_key.pub"].each do |key|
  remote_file "/tmp/#{key}" do
    source key
    mode "0600"
  end
end

remote_file "/tmp/git-ssh.sh" do
  remote_file "git-ssh.sh"
end

node[:django_deploy].each do |path, config|
  deploy path do
    repo config[:repo]
    revision config[:revision]
    git_ssh_wrapper "/tmp/git-ssh.sh"
    user "deploy"
    group "bueda"
    migrate false
    shallow_clone true
    restart_command "touch #{config[:wsgi_script]}"
    action :deploy
  end
end
