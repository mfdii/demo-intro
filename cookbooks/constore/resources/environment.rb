actions :upload
attribute :name, :kind_of => String, :name_attribute => true
attribute :environment_path, :kind_of => String, :name_attribute => true, :required => true
attribute :org_name, :kind_of => String, :required => true
attribute :server_url, :kind_of => String, :required => true
attribute :client_key, :kind_of => String, :required => true
attribute :client_name, :kind_of => String, :required => true
attribute :all, :kind_of => [FalseClass, TrueClass], :default => false
attribute :include_deps, :kind_of => [FalseClass, TrueClass], :default => false
