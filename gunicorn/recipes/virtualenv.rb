#
# Author:: Christopher Peplin <peplin@bueda.com>
# Cookbook Name:: gunicorn
# Recipe:: default
#
# Copyright 2010, Bueda, Inc.
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

include_recipe "gunicorn"

app = node.run_state[:current_app] 

%w{greenlet gevent gunicorn}.each do |package|
  pip_package package do
    virtualenv app[:virtualenv]
  end
end
