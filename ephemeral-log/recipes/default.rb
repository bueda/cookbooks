node[:ephemeral_log].each do |path, dev|
  mount path do
    device dev
    fstype "none"
    options "bind"
    action [:mount, :enable]
  end
end
