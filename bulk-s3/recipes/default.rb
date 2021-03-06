include_recipe "s3"

search(:apps) do |app|
  Chef::Log.debug("Running bulk-s3 for the #{app} app with " +
      "server roles #{app[:server_roles]} and this server has " +
      "#{node.run_list.roles}")
  next unless (app[:server_roles] & node.run_list.roles).length != 0
  next unless app[:s3] and app[:s3][:files]
  Chef::Log.debug("Decided to download the S3 files")
  app[:s3][:files].each do |name, config|
    directory File.dirname(name) do
      owner config[:owner]
      group config[:group]
      mode 0775
      recursive true
    end

    s3_file name do
      source "s3://#{config[:bucket]}/#{config[:file]}"
      access_key_id data_bag_item(:aws, :primary)['access_key_id']
      secret_access_key data_bag_item(:aws, :primary)['secret_access_key']
      owner "deploy"
      group "bueda"
      mode 0755
      checksum config[:checksum]
    end

    bash "extract" do
      action :nothing
      user config[:owner]
      cwd File.dirname(name)
      code "#{config[:extract_command]} #{File.basename(name)}"
      subscribes :run, resources(:s3_file => name), :immediately
    end if config[:extract_command]
  end
end

