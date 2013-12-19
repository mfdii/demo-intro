#
# Cookbook Name:: constore
# Recipe:: default
#
# Copyright 2013, Opscode, Inc.
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

directory node["constore"]["repo_dir"] do
	action :create
	recursive true
end



node["constore"]["repos"].each do |key,repos|

		directory "#{node["constore"]["repo_dir"]}/#{node["constore"]["repos"][key]["name"]}" do
			action :create
			recursive true
		end

		git "#{node["constore"]["repo_dir"]}/#{node["constore"]["repos"][key]["name"]}" do
			action :sync
			destination "#{node["constore"]["repo_dir"]}/#{node["constore"]["repos"][key]["name"]}"
			repository node["constore"]["repos"][key]["url"]
			notifies :upload, "constore_cookbook[#{node["constore"]["repo_dir"]}/#{node["constore"]["repos"][key]["name"]}/cookbooks]"			
			notifies :upload, "constore_role[#{node["constore"]["repo_dir"]}/#{node["constore"]["repos"][key]["name"]}/roles]"
			notifies :upload, "constore_environment[#{node["constore"]["repo_dir"]}/#{node["constore"]["repos"][key]["name"]}/environments]"
		end
		
		search(:constore_clients,"id:#{node["constore"]["repos"][key]["client_key"]}").each do |key_data|
			template "#{node["constore"]["repo_dir"]}/#{node["constore"]["repos"][key]["name"]}/#{node["constore"]["repos"][key]["client_name"]}.pem" do
				source "client.pem.erb"
				owner "root"
				group "root"
				mode "0600"
				variables(
					:clientkey => key_data["key"].join("\n")
				)
			end
		end

		constore_cookbook "#{node["constore"]["repo_dir"]}/#{node["constore"]["repos"][key]["name"]}/cookbooks" do
			action :nothing
			org_name node["constore"]["repos"][key]["org_name"]
			server_url "https://127.0.0.1/organizations/#{node["constore"]["repos"][key]["org_name"]}"
			client_key "#{node["constore"]["repo_dir"]}/#{node["constore"]["repos"][key]["name"]}/#{node["constore"]["repos"][key]["client_name"]}.pem"
			client_name node["constore"]["repos"][key]["client_name"]
		end

		constore_role "#{node["constore"]["repo_dir"]}/#{node["constore"]["repos"][key]["name"]}/roles" do
			action :nothing
			org_name node["constore"]["repos"][key]["org_name"]
			server_url "https://127.0.0.1/organizations/#{node["constore"]["repos"][key]["org_name"]}"
			client_key "#{node["constore"]["repo_dir"]}/#{node["constore"]["repos"][key]["name"]}/#{node["constore"]["repos"][key]["client_name"]}.pem"
			client_name node["constore"]["repos"][key]["client_name"]
		end

		constore_environment "#{node["constore"]["repo_dir"]}/#{node["constore"]["repos"][key]["name"]}/environments" do
			action :nothing
			org_name node["constore"]["repos"][key]["org_name"]
			server_url "https://127.0.0.1/organizations/#{node["constore"]["repos"][key]["org_name"]}"
			client_key "#{node["constore"]["repo_dir"]}/#{node["constore"]["repos"][key]["name"]}/#{node["constore"]["repos"][key]["client_name"]}.pem"
			client_name node["constore"]["repos"][key]["client_name"]
		end

end


