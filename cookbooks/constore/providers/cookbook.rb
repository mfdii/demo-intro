

require 'chef/rest'
require 'chef/cookbook_uploader'
require 'chef/cookbook_loader'

use_inline_resources

def whyrun_supported?
  true
end


action :upload do

	converge_by("Uploading Cookbooks in #{new_resource.cookbook_path}.") do

		rest = Chef::REST.new(new_resource.url,new_resource.client_name,new_resource.client_key)

		cu = Chef::CookbookUploader.new(Chef::CookbookLoader.load_cookbooks(new_resource.cookbook_path), new_resource.cookbook_path,{"rest" => rest})

		cu.upload_cookbooks

	end
end




