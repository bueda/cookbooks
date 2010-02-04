node[:ephemeral_log].each do |path, config|
  [path, config[:dev]].each do |dir|
    directory dir do
      owner config[:owner]
      group config[:group]
      mode "0775"
      recursive true
      action :create
      not_if "test -d #{dir}"
    end 
  end
  mount path do
    device config[:dev]
    fstype "none"
    options "bind"
    action [:mount, :enable]
  end
end
