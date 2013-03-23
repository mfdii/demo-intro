provides "ipaddress_internal"

require_plugin "#{os}::network"

network["interfaces"]["eth1"]["addresses"].each do |ip, params|
  if params['family'] == 'inet' then
      ipaddress_internal ip
  end
end
