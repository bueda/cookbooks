require 'resource/pip_package'

node[:virtualenv].each do |path, config|
  file path do
    owner config[:owner]
    group config[:group]
    mode config[:mode]
    action :create
  end

  config[:packages].each do |package|
    pip_package package do
      action :install
      virtualenv path
    end
  end if config[:packages]
  
  config[:vcs].each do |vcs|
    pip_package vcs do
      action :install_from_vcs
      virtualenv path
    end
  end if config[:vcs]
   
  config[:requirements].each do |requirements|
    pip_package requirements do
      action :install_requirements
      virtualenv path
    end
  end if config[:requirements]
end
