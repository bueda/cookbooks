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

include_recipe "s3"

easy_install_package "fabric"
easy_install_package "pip"

# easy_install_package checks for module.__path__ which virtualenv
# doesn't provide. Could be considered a bug in either Chef or virtualenv,
# but this works for now.
execute "easy_install virtualenv"

remote_file "/root/fab_shared.py" do
  source "s3://bueda.deploy/fab_shared.py"
  access_key_id data_bag_item(:aws, :primary)['access_key_id']
  secret_access_key data_bag_item(:aws, :primary)['secret_access_key']
  owner "root"
  group "root"
  mode 0755
end

node[:fab_deploy].each do |name, config|
  bash "fab #{name}" do
    action :nothing
    user config[:owner]
    cwd "/tmp/#{name}/#{config[:unit]}"
    environment 'PYTHONPATH' => '/root',
        'AWS_ACCESS_KEY_ID' => data_bag_item(:aws, :primary)['access_key_id'],
        'AWS_SECRET_ACCESS_KEY' => data_bag_item(:aws, :primary)['secret_access_key']
    code "fab localhost:deployment_type=#{config[:deployment_type]} deploy:release=#{config[:tag]},skip_tests=True,assume_yes=True"
  end

  bash "extract #{name}" do
    action :nothing
    user config[:owner]
    cwd "/tmp"
    code "mkdir -p #{name}; cd #{name}; tar -xzf /tmp/#{name}.tar.gz"
    notifies :run, resources(:bash => "fab #{name}"), :delayed
  end

  remote_file "/tmp/#{name}.tar.gz" do
    source config[:source]
    access_key_id data_bag_item(:aws, :primary)['access_key_id']
    secret_access_key data_bag_item(:aws, :primary)['secret_access_key']
    owner config[:owner]
    group config[:group]
    mode 0755
    notifies :run, resources(:bash => "extract #{name}"), :immediately
  end
end
