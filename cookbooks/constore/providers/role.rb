

use_inline_resources

def whyrun_supported?
  true
end


action :upload do

	converge_by("Uploading roles in #{new_resource.role_path}.") do

		#rest = Chef::REST.new(new_resource.server_url,new_resource.client_name,new_resource.client_key)
		#cl = Chef::CookbookLoader.new(new_resource.cookbook_path)
		#cu = Chef::CookbookUploader.new(cl.load_cookbooks, new_resource.cookbook_path,{"rest" => rest})

		#cu.upload_cookbooks

		files=Dir.glob("#{new_resource.role_path}/*.json") + Dir.glob("#{new_resource.role_path}/*.rb")

		execute "knife role from file" do
			command "knife role from file #{files.join(" ")} -s #{new_resource.server_url} -k #{new_resource.client_key} -u #{new_resource.client_name}"
			action :run
		end
		
		#blah


	end
end




