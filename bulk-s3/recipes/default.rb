include_recipe "s3"

node[:s3][:files].each do |name, config|
  directory File.dirname(name) do
    owner config[:owner]
    group config[:group]
    mode 0775
    recursive true
  end

  remote_file name do
    source "s3://#{config[:bucket]}/#{config[:file]}"
    access_key_id node[:s3][:access_key_id]
    secret_access_key node[:s3][:secret_access_key]
    owner "deploy"
    group "bueda"
    mode 0755
  end

  bash "extract" do
    action :nothing
    user config[:owner]
    cwd File.dirname(name)
    code "#{config[:extract_command]} #{File.basename(name)}"
    subscribes :run, resources(:remote_file => name), :immediately
  end if config[:extract_command]
end
