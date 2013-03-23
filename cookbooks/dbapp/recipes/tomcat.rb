#
# Author:: cookbooks@opscode.com
# Cookbook Name:: dbapp
# Recipe:: tomcat
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
# This is potentially destructive to the nodes mysql password attributes, since
# we iterate over all the app databags. If this database server provides
# databases for multiple applications, the last app found in the databags
# will win out, so make sure the databags have the same passwords set for
# the root, repl, and debian-sys-maint users.
#

include_recipe "tomcat"

app = node['apps']['dbapp']

# remove ROOT application
# TODO create a LWRP to enable/disable tomcat apps
directory "#{node['tomcat']['webapp_dir']}/ROOT" do
  recursive true
  action :delete

  not_if "test -L #{node['tomcat']['context_dir']}/ROOT.xml"
end

link "#{node['tomcat']['context_dir']}/ROOT.xml" do
  to "#{app['deploy_to']}/shared/dbapp.xml"

  notifies :stop, resources(:service => "tomcat")
  notifies :start, resources(:service => "tomcat")
end

#service "tomcat" do
#  service_name "tomcat6"
#  retries 3
#  retry_delay 5
#  action [ :stop, :start ]
#  not_if "test -d #{node['tomcat']['home']}-admin"
#end

directory app['deploy_to'] do
  owner app['owner']
  group app['group']
  mode '0755'
  recursive true
end

directory "#{app['deploy_to']}/releases" do
  owner app['owner']
  group app['group']
  mode '0755'
  recursive true
end

directory "#{app['deploy_to']}/shared" do
  owner app['owner']
  group app['group']
  mode '0755'
  recursive true
end

%w{ log pids system }.each do |dir|

  directory "#{app['deploy_to']}/shared/#{dir}" do
    owner app['owner']
    group app['group']
    mode '0755'
    recursive true
  end

end

db_search = ruby_block "search for database" do
  block do
    dbm = nil
    if app['tier'].include?('db')
      dbm = node

    else
      dbm = search("node", "apps_dbapp_tier:db AND apps_dbapp_db_type:master AND chef_environment:#{node.chef_environment}").last

    end

    if dbm.nil?
      node.save
      raise( %Q(Unable to find database host where attribute node['apps']['dbapp']['tier'] contains 'db') )

    else
      server_ip = begin
        if dbm.has_key?('ipaddress_internal')
          dbm['ipaddress_internal']
        elsif dbm.has_key?('ec2')
          dbm['ec2']['public_ipv4']
        elsif ! dbm['ipaddress'].nil?
          dbm['ipaddress']
        else
          dbm['fqdn']
        end
      end
      Chef::Log.info( %Q(Database server ip is "#{server_ip}") )
      node.run_state['dbm'] = server_ip

    end
  end

  action :nothing

  retries app['search']['retries']
  retry_delay app['search']['retry_delay']

  only_if { app.has_key?('db') }

end
db_search.run_action(:create)

template "#{app['deploy_to']}/shared/dbapp.xml" do
  dbm = node.run_state['dbm']

  source "context.xml.erb"
  owner app[:owner]
  group app[:group]
  mode "644"
  variables(
    :host => dbm,
    :app => 'dbapp',
    :database => app['db'],
    :war => "#{app['deploy_to']}/releases/#{app['checksum']}.war"
  )
  not_if { node.run_state['dbm'].nil? }
end

directory "#{node['tomcat']['webapp_dir']}/ROOT" do
  recursive true
  action :nothing
end

remote_file 'dbapp artifacts' do
  path "#{app['deploy_to']}/releases/#{app['checksum']}.war"
  source app['source']
  mode "0644"
  checksum app['checksum']
  notifies :delete, resources(:directory => "#{node['tomcat']['webapp_dir']}/ROOT")
end

node.default['apps']['dbapp']['tier'] << 'app'

