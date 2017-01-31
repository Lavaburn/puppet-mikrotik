Puppet::Type.newtype(:mikrotik_ppp_profile) do
  apply_to_device

  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name) do
    desc 'PPP profile name'
    isnamevar
  end

  newproperty(:local_address) do
    desc 'The local address to use for PPP session'
  end  
  
  newproperty(:remote_address) do
    desc 'The remote address (or IP pool) to use for PPP session'
  end  

  newproperty(:bridge) do
    desc 'The bridge to assign the PPP session to'
  end  
  
  newproperty(:bridge_path_cost ) do
    desc 'The path cost for the session when assigned to a bridge'
  end  
  
  newproperty(:bridge_port_priority) do
    desc 'The port priority for the session when assigned to a bridge'
  end  
  
  newproperty(:incoming_filter) do
    desc 'The filter to use for incoming connections'
  end  
  
  newproperty(:outgoing_filter) do
    desc 'The filter to use for outgoing connections'
  end  
  
  newproperty(:address_list) do
    desc 'Address list to add active sessions on'
  end  

  newproperty(:dns_server) do
    desc 'DNS Server to assign to the PPP client'
  end  
  
  newproperty(:wins_server) do
    desc 'WINS Server to assign to the PPP client'
  end  

  newproperty(:change_tcp_mss) do
    desc 'Whether to change TCP MSS'
    defaultto :default
    newvalues(:yes, :no, :default)
  end  
  
  newproperty(:use_upnp) do
    desc 'Whether to use uPnP'
    defaultto :default
    newvalues(:yes, :no, :default)
  end  

  newproperty(:use_mpls) do
    desc 'Whether to use MPLS'
    defaultto :default
    newvalues(:yes, :no, :required, :default)
  end
  
  newproperty(:use_compression) do
    desc 'Whether to use compression'
    defaultto :default
    newvalues(:yes, :no, :default)
  end
  
  newproperty(:use_encryption) do
    desc 'Whether to use encryption'
    defaultto :default
    newvalues(:yes, :no, :required, :default)
  end
  
  newproperty(:session_timeout) do
    desc 'The maximum time the connection can stay up'
  end  

  newproperty(:idle_timeout) do
    desc 'The time limit when the link will be terminated if there is no activity'
  end  

  newproperty(:rate_limit) do
    desc 'Data rate limitations for the client'
  end  

  newproperty(:only_one) do
    desc 'Whether to allow only one session per user'
    defaultto :default
    newvalues(:yes, :no, :default)
  end

  newproperty(:insert_queue_before) do
    desc 'Add queue for session and insert before'
  end 

  newproperty(:parent_queue) do
    desc 'Attach queue for session to parent queue'
  end  

  newproperty(:queue_type) do
    desc 'Set type for queue for session'
  end

  newproperty(:on_up) do
    desc 'Action to perform on up'
  end  

  newproperty(:on_down) do
    desc 'Action to perform on down'
  end  
end
