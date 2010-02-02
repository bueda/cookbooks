require 'chef-deploy'

directory "/root/.ssh" do
    owner "root"
    group "root"
    mode "0600"
    not_if "test -d /root/.ssh"
end

remote_file "/root/.ssh/id_rsa" do
    source "deploy_key"
    mode "0600"
end

remote_file "/root/.ssh/id_rsa.pub" do
    source "deploy_key.pub"
    mode "0600"
end

node[:django_deploy].each do |path, config|
  deploy path do
    repo config[:repo]
    revision config[:revision]
    user "deploy"
    group "bueda"
    migrate false
    shallow_clone true
    restart_command "touch #{config[:wsgi_script]}"
    action :deploy
  end
end
