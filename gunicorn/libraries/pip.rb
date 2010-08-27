#
# Author:: Christopher Peplin (<peplin@bueda.com>)
# Copyright:: Copyright (c) 2010 Christopher Peplin
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider/package/easy_install'
require 'chef/resource/package'

class Chef
  class Resource
    class PipPackage < Chef::Resource::EasyInstallPackage

      def initialize(name, run_context=nil)
        super
        @resource_name = :pip_package
        @provider = Chef::Provider::Package::Pip
      end

      def pip_binary(arg=nil)
        set_or_return(
          :pip_binary,
          arg,
          :kind_of => [ String ]
        )
      end

      def virtualenv(arg=nil)
        set_or_return(
          :virtualenv,
          arg,
          :kind_of => [ String ]
        )
      end

      def file(arg=nil)
        set_or_return(
          :file,
          arg,
          :kind_of => [ String ]
        )
      end

      def scm(arg=nil)
        set_or_return(
          :scm,
          arg,
          :kind_of => [ String ]
        )
      end

    end
  end
end

class Chef
  class Provider
    class Package
      class Pip < Chef::Provider::Package::EasyInstall

        include Chef::Mixin::ShellOut

        def installed_version(name)
          installed_version = nil

          command = "#{pip_binary_path} freeze"
          if @new_resource.virtualenv
              command += " -E #{@new_resource.virtualenv}"
          end
          command += " | grep -i #{@new_resource.package_name}"

          begin
              output = shell_out!(command).stdout
              output[/#{@new_resource.package_name}==(.*)/i]
              installed_version = $1
          rescue
              installed_version = nil
          end

          installed_version
        end

        def pip_binary_path
          path = @new_resource.pip_binary
          path ? path : 'pip'
        end

        def load_current_resource
          @current_resource = Chef::Resource::Package.new(@new_resource.name)
          @current_resource.package_name(@new_resource.package_name)
          @current_resource.version(nil)

          package_version = installed_version(@new_resource.package_name)
          if package_version == @new_resource.version
            Chef::Log.debug("#{@new_resource.package_name} at version #{@new_resource.version}")
            @current_resource.version(@new_resource.version)
          else
            Chef::Log.debug("#{@new_resource.package_name} at version #{package_version}")
            @current_resource.version(package_version)
          end

          @current_resource
        end

        def install_from_scm(name, version)
          if @new_resource.virtualenv
            run_command(:command => 
              "pip install -q -s -E #{@new_resource.virtualenv} -e #{@new_resource.scm}#egg=#{name}")
          else
            run_command(:command => "pip install -q -e #{@new_resource.scm}#egg=#{name}")
          end
        end

        def install_from_file(name, version)
          if @new_resource.virtualenv
            run_command(:command => 
              "pip install -q -s -E #{@new_resource.virtualenv} #{@new_resource.file}")
          else
            run_command(:command => "pip install -q #{@new_resource.file}")
          end
        end

        def install_package(name, version)
          if @new_resource.file
            install_from_file name, version
          elsif @new_resource.scm
            install_from_scm name, version
          end
          command = "#{pip_binary_path} install -q "
          if @new_resource.virtualenv
            command += "-s -E #{@new_resource.virtualenv}"
          end
          command += " \"#{name}==#{version}\""
          run_command(:command => command)
        end

        def remove_package(name, version)
          command = "#{pip_binary_path} uninstall -q "
          if @new_resource.virtualenv
            command += "-s -E #{@new_resource.virtualenv}"
          end
          command += " #{name}"
          run_command(:command => command)
        end

      end
    end
  end
end
