groups = search(:groups)

groups.each do |group|
  group group[:id] do
    group_name group[:id]
    gid group[:gid]
    action [ :create, :modify, :manage ]
  end

  if node[:active_groups].include?(group[:id])
    search(:users, "groups:#{group[:id]}").each do |user|
      home_dir = user[:home_dir] || "/home/#{user[:id]}"

      user user[:id] do
        comment user[:full_name]
        uid user[:uid]
        gid user[:groups].first
        home home_dir
        shell user[:shell]
        action [:create, :manage]
      end
      
      user[:groups].each do |g|
        group g do
          group_name g.to_s
          gid groups.find { |grp| grp[:id] == g }[:gid]
          members [user[:id]]
          append true
          action [ :create, :modify, :manage ]
        end
      end

      directory "#{home_dir}" do
        owner user[:id]
        group user[:groups].first.to_s
        mode 0700
      end

      directory "#{home_dir}/.ssh" do
        action :create
        owner user[:id]
        group user[:groups].first.to_s
        mode 0700
      end

      template "#{home_dir}/.ssh/authorized_keys" do
        source "authorized_keys.erb"
        action :create
        owner user[:id]
        group user[:groups].first.to_s
        variables(:keys => user[:ssh_keys])
        mode 0600
        only_if do user[:ssh_keys] end
      end
    end
  end
end

# Remove initial setup user and group.
user  "ubuntu" do
  action :remove
end

group "ubuntu" do
  action :remove
end
