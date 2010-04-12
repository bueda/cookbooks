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

remote_file "/tmp/fab_shared.py" do
  source config[:source]
  owner config[:owner]
  group config[:group]
  mode 0755
end

node[:fab_deploy].each do |name, config|
  remote_file "/tmp/#{name}.tar.gz" do
    source config[:source]
    owner config[:owner]
    group config[:group]
    mode 0755
  end

  bash "extract" do
    user config[:owner]
    cwd "/tmp"
    code "tar -xzf /tmp/#{name}.tar.gz"
  end

  bash "fab" do
    user config[:owner]
    cwd "/tmp/#{name}"
    # TODO better way to handle the path, witha config param?
    code "PYTHONPATH=/root fab localhost deploy:skip_tests=True"
  end
end
