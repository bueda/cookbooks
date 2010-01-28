require 'resource/pip_package.rb'
require 'chef/resource/easy_install_package'

easy_install_package "python-pip"
pip_package "virtualenv"

node[:virtualenv].each do |path, config|
  config[:packages].each do |package|
    pip_package package do
      action :install
      virtualenv path
    end
  end if config[:packages]
  
  config[:vcs].each do |name, url|
    pip_package name do
      action :install_from_vcs
      source url
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
