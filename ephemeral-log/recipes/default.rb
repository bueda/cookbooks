node[:ephemeral_log].each do |path, dev|
  [path, dev].each do |dir|
    directory dir do
      owner "root"
      group "root"
      mode "0775"
      recursive true
      action :create
      not_if "test -d #{dir}"
    end 
  end
  mount path do
    device dev
    fstype "none"
    options "bind"
    action [:mount, :enable]
  end
end
