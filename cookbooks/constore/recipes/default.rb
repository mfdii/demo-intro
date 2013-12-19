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

		repo_dir = node["constore"]["repo_dir"]
		current_repo = node["constore"]["repos"][key]

		directory "#{repo_dir}/#{current_repo["name"]}" do
			action :create
			recursive true
		end

		git "#{repo_dir}/#{current_repo["name"]}" do
			action :sync
			destination "#{repo_dir}/#{current_repo["name"]}"
			repository current_repo["url"]
			notifies :upload, "constore_cookbook[#{repo_dir}/#{current_repo["name"]}/cookbooks]"			
			notifies :upload, "constore_role[#{repo_dir}/#{current_repo["name"]}/roles]"
			notifies :upload, "constore_environment[#{repo_dir}/#{current_repo["name"]}/environments]"
		end
		
		search(:constore_clients,"id:#{current_repo["client_key"]}").each do |key_data|
			template "#{repo_dir}/#{current_repo["name"]}/#{current_repo["client_name"]}.pem" do
				source "client.pem.erb"
				owner "root"
				group "root"
				mode "0600"
				variables(
					:clientkey => key_data["key"].join("\n")
				)
			end
		end

		constore_cookbook "#{repo_dir}/#{current_repo["name"]}/cookbooks" do
			action :nothing
			org_name current_repo["org_name"]
			server_url "https://127.0.0.1/organizations/#{current_repo["org_name"]}"
			client_key "#{repo_dir}/#{current_repo["name"]}/#{current_repo["client_name"]}.pem"
			client_name current_repo["client_name"]
		end

		constore_role "#{repo_dir}/#{current_repo["name"]}/roles" do
			action :nothing
			org_name current_repo["org_name"]
			server_url "https://127.0.0.1/organizations/#{current_repo["org_name"]}"
			client_key "#{repo_dir}/#{current_repo["name"]}/#{current_repo["client_name"]}.pem"
			client_name current_repo["client_name"]
		end

		constore_environment "#{repo_dir}/#{current_repo["name"]}/environments" do
			action :nothing
			org_name current_repo["org_name"]
			server_url "https://127.0.0.1/organizations/#{current_repo["org_name"]}"
			client_key "#{repo_dir}/#{current_repo["name"]}/#{current_repo["client_name"]}.pem"
			client_name current_repo["client_name"]
		end

end


