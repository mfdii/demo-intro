#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: dbapp
# Recipe:: db_bootstrap
#
# Copyright 2010, Opscode, Inc.
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

service "tomcat" do
  service_name "tomcat6"
  retries 3
  retry_delay 5
  action [ :stop, :start ]
  not_if "test -d #{node['tomcat']['home']}-admin"
end
