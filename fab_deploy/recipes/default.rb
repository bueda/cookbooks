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

# TODO use this once chef is updated on servers
# easy_install_package "fabric"
# easy_install_package "pip"
# easy_install_package "virtualenv"

execute "easy_install fabric"
execute "easy_install pip"
execute "easy_install virtualenv"

remote_file "/root/fab_shared.py" do
  source "s3://bueda.deploy/fab_shared.py"
  access_key_id node[:s3][:access_key_id]
  secret_access_key node[:s3][:secret_access_key]
  owner "root"
  group "root"
  mode 0755
end

node[:fab_deploy].each do |name, config|
  remote_file "/tmp/#{name}.tar.gz" do
    source config[:source]
    access_key_id node[:s3][:access_key_id]
    secret_access_key node[:s3][:secret_access_key]
    owner config[:owner]
    group config[:group]
    mode 0755
  end

  bash "extract #{name}" do
    action :nothing
    user config[:owner]
    cwd "/tmp"
    code "tar -xzf /tmp/#{name}.tar.gz"
    subscribes :run, resources(:remote_file => "/tmp/#{name}.tar.gz"), :immediately
  end

  bash "fab #{name}" do
    action :nothing
    user config[:owner]
    cwd "/tmp/#{name}"
    environment 'PYTHONPATH' => '/root'
    code "fab localhost deploy:release=HEAD,skip_tests=True,assume_yes=True"
    subscribes :run, resources(:bash => "extract #{name}"), :immediately
  end

  bash "cleanup #{name}" do
    action :nothing
    user config[:owner]
    cwd "/tmp"
    code "rm -rf #{name} #{name}.tar.gz"
    ignore_failure true
    subscribes :run, resources(:bash => "extract #{name}")
  end
end
