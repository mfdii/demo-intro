#Knife invocations supply FQDN as the node name at creation time and this becomes hostname( option -N)

#Ensure the hostname of the system is set to knife provided node name
file "/etc/hostname" do
  content node.name
  notifies :run, resources(:execute => "Configure Hostname"), :immediately
end

#This sets up script which will run whenever eth0 comes up(after reboot) to update /etc/hosts
cookbook_file "/etc/network/if-up.d/update_hosts" do
  source "update_hosts.sh"
  owner "root"
  group "root"
  mode 0555
  backup false
  notifies :run, resources(:execute=> "update_hosts"), :immediately
end

#Execute this script now (firsttime) to set /etc/hosts to have the newly provisioned nodes address/hostname line
bash "update_hosts" do
  user "root"
  group "root"
  cwd "/tmp"
  code %Q(IFACE=eth0 /etc/network/if-up.d/update_hosts)
  :nothing
end