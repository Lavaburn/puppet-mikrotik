Puppet::Type.newtype(:mikrotik_queue_type) do
  apply_to_all

  ensurable do
    defaultto :present

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    def retrieve
      provider.getState
    end

    def insync?(is)
      @should.each { |should|
        case should
          when :present
            return (provider.getState != :absent)
          when :absent
            return (provider.getState == :absent)
        end
      }
    end
  end

  newparam(:name) do
    desc 'Queue type name'
    isnamevar
  end

  newproperty(:kind) do
    desc 'Queue discipline (pcq, pfifo, bfifo, sfq, red, sfq)'
    newvalues(:pcq, :pfifo, :bfifo, :sfq, :red)
  end

  newproperty(:pcq_classifier, array_matching: :all) do
    desc 'PCQ classifier fields (e.g. src-address, dst-address)'

    def insync?(is)
      if is.is_a?(Array) && @should.is_a?(Array)
        is.sort == @should.sort
      else
        is == @should
      end
    end
  end

  newproperty(:pcq_rate) do
    desc 'PCQ per-flow rate limit (e.g. 10M, 256k)'
  end

  newproperty(:pcq_total_limit) do
    desc 'PCQ total queue size limit (e.g. 2500KiB)'
  end

  newproperty(:pcq_dst_address6_mask) do
    desc 'IPv6 destination prefix length for PCQ classification'
  end

  newproperty(:pcq_src_address6_mask) do
    desc 'IPv6 source prefix length for PCQ classification'
  end
end
