#
# Author:: cookbooks@opscode.com
# Cookbook Name:: dbapp
# Recipe:: db_bootstrap
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

#dbm = search(:node, "apps_dbapp_tier:db AND chef_environment:#{node.chef_environment}").last
#
#if node['apps']['dbapp']['tier'].include?('db')
#  dbm = node
#end
#
#if dbm.nil?
#  raise( %Q(Unable to find database host with atrribute node['apps']['dbapp']['tier'] = 'db') )
#
#else
#  Chef::Log.info( %Q(Dependent DB node is set to other "#{dbm.name}") )
#
#end

cookbook_file "/tmp/schema.sql" do
  source "schema.sql"
  mode 0755
  owner "root"
  group "root"
end

#This needs to be converted to LWRP's and have the db driver driven through attributes
execute "create database" do
  command %Q(/usr/bin/mysql -u root -p#{node['mysql']['server_root_password']} -e "CREATE DATABASE IF NOT EXISTS #{node['apps']['dbapp']['db']['name']};")
  action :run
end

execute "bootstrap database" do
  command %Q(/usr/bin/mysql -u #{node['apps']['dbapp']['db']['username']} -p#{node['apps']['dbapp']['db']['password']} #{node['apps']['dbapp']['db']['name']} < /tmp/schema.sql)
  action :run

  notifies :create, "ruby_block[rm db_bootstrap from runlist]", :immediately
end

ruby_block "rm db_bootstrap from runlist" do
  block do
    Chef::Log.info("Database Bootstrap completed, removing the destructive recipe[dbapp::db_bootstrap]")
    node.run_list.remove("recipe[dbapp::db_bootstrap]") if node.run_list.include?("recipe[dbapp::db_bootstrap]")
  end
  action :nothing
end
