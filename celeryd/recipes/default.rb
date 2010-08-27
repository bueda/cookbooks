#
# Cookbook Name:: celery
# Recipe:: default
#
# Copyright 2010, Bueda Inc.
#
# All rights reserved - Do Not Redistribute
#

require_recipe "god"

search(:apps, "*:*") do |app|
    god_monitor app[:id] do
        config "celeryd.god.erb"
    end
end
