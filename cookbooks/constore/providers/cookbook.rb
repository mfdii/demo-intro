

require 'chef/rest'
require 'chef/cookbook_uploader'
require 'chef/cookbook_loader'

use_inline_resources

def whyrun_supported?
  true
end


action :upload do

	converge_by("Uploading Cookbooks in #{@new_resource.cookbook_path}.") do

		#rest = Chef::REST.new(new_resource.url,new_resource.client_name,new_resource.client_key)
		#cl = Chef::CookbookLoader.new(new_resource.cookbook_path)
		#cu = Chef::CookbookUploader.new(cl.load_cookbooks, new_resource.cookbook_path,{"rest" => rest})

		#cu.upload_cookbooks

		execute "knife cookbook upload" do
			command "knife cookbook upload -a -s #{@new_resource.url} -o #{@new_resource.cookbook_path} -k #{@new_resource.client_key}"
			action :run
		end
		
		#blah


	end
end




