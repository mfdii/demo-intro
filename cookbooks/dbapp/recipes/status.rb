#
# Author:: cookbooks@opscode.com
# Cookbook Name:: dbapp
# Recipe:: status
#
# Copyright 2009-2013, Opscode, Inc.
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

title = "Java Web App Quick Start"
organization = Chef::Config[:chef_server_url].split('/').last
pretty_run_list = node.run_list.run_list_items.collect do |item|
  "#{item.name} (#{item.type.to_s})"
end.join(", ")

directory "#{node.tomcat.webapp_dir}/ROOT" do
  owner node.tomcat.user
  group node.tomcat.group
  mode "0755"
  notifies :create, "template[#{node.tomcat.webapp_dir}/ROOT/status.html]"
end

template "#{node.tomcat.webapp_dir}/ROOT/status.html" do
  source "status.html.erb"
  owner node.tomcat.user
  group node.tomcat.group
  mode "0755"
  variables(
    :app => node.apps.dbapp,
    :title => title,
    :organization => organization,
    :run_list => pretty_run_list
  )
  action :nothing
end
