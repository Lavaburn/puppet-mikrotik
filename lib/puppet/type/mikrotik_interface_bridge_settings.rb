Puppet::Type.newtype(:mikrotik_interface_bridge_settings) do
  apply_to_all
  
  # Only 1 set of settings that is always enabled. NOT ensurable 
  
  newparam(:name) do
    desc 'Name should be -bridge-'
    isnamevar
  end

  newproperty(:allow_fast_path) do
    desc 'Whether to allow Fast Path'
    newvalues(true, false)
  end
  
  newproperty(:use_ip_firewall) do
    desc 'Whether to use IP Firewall for bridged traffic'
    newvalues(true, false)
  end
  
  newproperty(:use_ip_firewall_for_pppoe) do
    desc 'Whether to use IP Firewall for PPPoE encapsulated traffic on the bridge [DANGER!]'
    newvalues(true, false)
  end
  
  newproperty(:use_ip_firewall_for_vlan) do
    desc 'Whether to use IP Firewall for VLAN encapsulated traffic on the bridge'
    newvalues(true, false)
  end
end
