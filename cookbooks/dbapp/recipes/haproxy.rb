#
# Author:: cookbooks@opscode.com
# Cookbook Name:: dbapp
# Recipe:: haproxy
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

include_recipe 'haproxy::default'

lb_search = ruby_block "search for haproxy members" do
  block do
    pool_members = search("node", "apps_dbapp_tier:app AND chef_environment:#{node.chef_environment} NOT name:#{node.name}")
    if node['apps']['dbapp']['tier'].include?('app')
      pool_members << node
    end

    if pool_members.empty?
      node.save
      raise( %Q(Unable to find haproxy member whose node attribute node['apps']['dbapp']['tier'] is 'app') )

    else
      pool_members.map! do |member|
        server_ip = begin
          if member.attribute?('ipaddress_internal')
            member['ipaddress_internal']

         elsif member.attribute?('cloud')
            if node.attribute?('cloud') && (member['cloud']['provider'] == node['cloud']['provider'])
               member['cloud']['local_ipv4']
            else
              member['cloud']['public_ipv4']
            end
  
          else
            member['ipaddress']

          end
        end
        { :ipaddress => server_ip, :hostname => member['hostname'] }
      end

      Chef::Log.info( %Q(Pool members for haproxy "#{pool_members.to_s}") )
      node.run_state['pool_members'] = pool_members

    end

  end

  action :nothing

  retries node[:haproxy][:search][:retries]
  retry_delay node[:haproxy][:search][:retry_delay]

end
lb_search.run_action(:create)

template "/etc/haproxy/haproxy.cfg" do
  pool_members = node.run_state['pool_members'] || []

  cookbook 'haproxy'
  source "haproxy-app_lb.cfg.erb"
  variables(
    :pool_members => pool_members,
    :defaults_options => defaults_options,
    :defaults_timeouts => defaults_timeouts
  )

  notifies :stop, "service[haproxy]"
  notifies :start, "service[haproxy]"
end

node.default['apps']['dbapp']['tier'] << 'lb'

