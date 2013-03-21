# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'ridley'
require 'pathname'
require 'openssl'
require 'date'

URL = 'https://chef.localdomain/organizations/opscode'
C_NAME = 'chef'
C_FILE = "#{ENV['HOME']}/.chef/chef@chef.localdomain.pem"

exp_date = Date.today
org_name = Pathname.new(URL).basename

conn = Ridley.connection({
    server_url: URL,
    organization: org_name,
    client_name: C_NAME,
    client_key: C_FILE,
    ssl: { verify: false }
})
nodes_to_clean = conn.search(:node, "expiration:[2012-01-01 TO #{exp_date}]")
nodes_to_clean.each do |n_obj|
  puts "Reaping [#{n_obj.name}]"

  c_obj = conn.client.find(n_obj.name)

#  c_obj.destroy
  conn.client.delete(c_obj)
#  n_obj.destroy
  conn.node.delete(n_obj)

end
