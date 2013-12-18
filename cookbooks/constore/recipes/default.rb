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
			revision "master"
		end

end


