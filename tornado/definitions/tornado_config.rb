#
# Author:: Christopher Peplin <peplin@bueda.com>
# Cookbook Name:: tornado
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

define :tornado_config, :port => 8888, :log_file_prefix => nil,
        :logging => "info", :notifies => nil, :owner => nil, :group => nil,
        :mode => nil do

  config_dir = File.dirname(params[:name])

  directory config_dir do
    recursive true
    action :create
  end

  template params[:name] do
    source "tornado.py.erb"
    cookbook "tornado"
    mode "0644"
    owner params[:owner] if params[:owner]
    group params[:group] if params[:group]
    mode params[:mode]   if params[:mode]
    variables params
    notifies *params[:notifies] if params[:notifies]
  end
end
