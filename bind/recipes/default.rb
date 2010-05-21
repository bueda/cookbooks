node[:bind].each do |path, config|
  if not File.exists?(config[:dev])
    if File.exists?(path)
      FileUtils.mv path, config[:dev]
    else
      directory config[:dev] do
        owner config[:owner]
        group config[:group]
        mode "0775"
        recursive true
        action :create
      end 
    end
  end

  directory path do
    owner config[:owner]
    group config[:group]
    mode "0775"
    recursive true
    action :create
  end

  mount path do
    device config[:dev]
    fstype "none"
    options "bind"
    action [:mount, :enable]
  end
end
