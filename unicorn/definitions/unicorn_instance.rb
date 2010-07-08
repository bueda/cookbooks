define :unicorn_instance, :enable => true do
  template params[:conf_path] do
    source "unicorn.conf.erb"
    cookbook "unicorn"
    variables params
  end
end
