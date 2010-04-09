#
# Author:: Christopher Peplin (<peplin@bueda.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
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

class Chef::Provider::RemoteFile
  include S3RemoteFile
end


node[:fab_deploy].each do |name, config|
  if not File.exists?(
      "/#{config[:deploy_parent]}/releases/#{config[:deploy_target]}") then

    releases_directory = config[:releases_directory] || node[:releases_directory]
    directory "/#{config[:deploy_parent]}/#{name}/#{releases_directory}" do
      owner config[:owner]
      group config[:group]
      mode 0775
      recursive true
    end

    packages_directory = config[:packages_directory] || node[:packages_directory]
    directory "/#{config[:deploy_parent]}/#{name}/#{packages_directory}" do
      owner config[:owner]
      group config[:group]
      mode 0775
      recursive true
    end

    remote_file "/#{config[:deploy_parent]}/#{name}/#{packages_directory}/#{config[:deploy_target])}" do
      source config[:source]
      owner config[:owner]
      group config[:group]
      mode 0755
    end

    bash "deploy" do
      user "root"
      cwd "/#{config[:deploy_parent]}/#{name}/#{packages_directory}"
      code <<-EOH
      tar -xzf #{config[:file]}
      mv #{config[:extracted_folder]} #{config[:deploy_parent]}/#{releases_directory}/#{config[:deploy_target]}
      chown #{config[:owner]}:#{config[:group]} -R #{config[:deploy_parent]}/#{releases_directory}/#{config[:deploy_target]}
      chmod 775 -R #{config[:deploy_parent]}/#{releases_directory}/#{config[:deploy_target]}
      EOH
    end

    link "/#{config[:deploy_parent]}/#{releases_directory]}/#{config[:symlink]}" do
      to "#{config[:deploy_parent]}/#{releases_directory}/#{config[:deploy_target]}"
      not_if do File.exists?("/#{config[:deploy_parent]}/#{releases_directory]}/#{config[:symlink]}") end
    end
  end
end
