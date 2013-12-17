# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'chef/environment'
require 'chef/knife'
require 'chef/knife/cookbook_upload'
require 'chef'

require 'digest'

ID = Time.new.strftime("%Y%m%d_%H_%M_%S")

Vagrant::Config.run do |config|

    config.vm.box = "ubuntu"

    {
      :tomcat => {
          :ip       => '192.168.65.91',
          :memory   => 756,
          :env      => 'Advanced',
          :run_list => %w( role[base_ubuntu] ),
      },
      :tomcat2 => {
          :ip       => '192.168.65.92',
          :memory   => 756,
          :env      => 'Advanced',
          :roles => %w( base_ubuntu fe_tomcat ),
      },
      :lb => {
          :ip       => '192.168.65.131',
          :memory   => 256,
          :env      => 'Advanced',
          :roles     => %w( base_ubuntu tomcat_fe_lb ),
      },

    }.each do |name,cfg|

        group_label = cfg[:env]
        chef_env = create_chef_env(group_label)

        hash = Digest::MD5.new.hexdigest(chef_env)
        vagrant_group = "/#{ chef_env.sub('-','/') }"

        config.vm.define name do |vm_cfg|
            vm_cfg.vm.host_name = "#{ name.to_s.sub('_','-') }-intro"
            if m = vm_cfg.vm.host_name.match(/[0-9]$/) then
                vm_cfg.vm.host_name.insert(0, "#{m}.")
            else
                vm_cfg.vm.host_name.chop
                vm_cfg.vm.host_name.insert(0, '1-')
            end
            vm_cfg.vm.network :hostonly, cfg[:ip] if cfg[:ip]
            vm_cfg.vm.box = cfg[:box] if cfg[:box]

            vm_cfg.vm.customize ["modifyvm", :id, "--name", vm_cfg.vm.host_name]
            vm_cfg.vm.customize ["modifyvm", :id, "--memory", cfg[:memory]]
            vm_cfg.vm.customize ["modifyvm", :id, "--groups", vagrant_group]
            vm_cfg.vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
          
            if cfg[:forwards]
              cfg[:forwards].each do |from,to|
                vm_config.vm.forward_port from, to
              end 
            end
    
            vm_cfg.vm.provision :chef_client do |chef|
                chef.chef_server_url = "https://chef11/organizations/opscode"
                chef.validation_key_path = "#{ENV['HOME']}/.chef/opscode-validator-chef11.pem"
                chef.validation_client_name = "opscode-validator"
                chef.node_name = vm_cfg.vm.host_name
                chef.provisioning_path = "/etc/chef"
                chef.log_level = :info
    #            chef.output = 'doc'
                chef.environment = chef_env
                chef.json = cfg[:attr] if cfg[:attr].is_a?(Hash)
    
                if cfg[:run_list].nil? then
                    cfg[:roles] ||= []
                    cfg[:roles].each { |r| chef.add_role(r) }
                    cfg[:recipes] ||= []                
                    cfg[:recipes].each { |r| chef.add_recipe(r) }
                else
                    chef.run_list = cfg[:run_list]
                end
    
            end
    
        end
    
    end

end

def create_chef_env(ce = '_default')
    Chef::Config.from_file("#{ENV['HOME']}/.chef/knife.rb")

    if ce.nil? then
        ce = '_default'

    else
        env_obj = Chef::Environment.new
        env_obj.name( ce )
      
        begin
            env_obj = Chef::Environment.load( ce )

        rescue Net::HTTPServerException => e
            raise e unless e.response.code == "404"
            env_obj.default_attributes['created_by'] ||= 'Vagrant'
            env_obj.default_attributes['created_date'] ||= Time.new.strftime("%Y_%m_%d-%H:%M:%S")

            env_obj.override_attributes( { 'apps' => { 'dbapp' => {} } } )

            env_obj.create
        end

    end

    return ce
end


__END__

