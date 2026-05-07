require 'puppet/util/network_device'
require_relative 'facts'
require_relative '../transport/mikrotik'

class Puppet::Util::NetworkDevice::Mikrotik::Device
  attr_reader :connection
  attr_accessor :url, :transport

  # Features whose cached results must be cleared on each device transition so
  # that ros_v6/ros_v7 are re-evaluated against the new device.
  MIKROTIK_VERSION_FEATURES = [:ros_v6, :ros_v7, :ros_v7_12, :ros_v7_pre12].freeze

  def initialize(url, options = {})
    # Puppet 5 support
    if Gem::Version.new(Puppet.version) < Gem::Version.new("6.0.0")
      @autoloader = Puppet::Util::Autoload.new(self, 'puppet/util/network_device/transport')
      @autoloader.load('mikrotik')
    end

    @transport = Puppet::Util::NetworkDevice::Transport::Mikrotik.new(url, options[:debug])

    # In a multi-device `puppet device` run, provider selection (defaultprovider)
    # and Puppet::Util::Feature results are cached at the class level and survive
    # across device transitions.  Clear them here — before any to_ral / provider
    # assignment happens for this device — so each device gets fresh selection.
    _reset_version_caches
  end

  def facts
    @facts ||= Puppet::Util::NetworkDevice::Mikrotik::Facts.new(@transport)

    @facts.retrieve
  end

  private

  def _reset_version_caches
    # 1. Clear cached feature results so ros_v6/ros_v7 blocks re-run.
    if (results = Puppet.features.instance_variable_get(:@results))
      MIKROTIK_VERSION_FEATURES.each { |f| results.delete(f) }
    end

    # 2. Clear @defaultprovider on every type whose cached default is one of
    #    the version-split Mikrotik providers (mikrotik_api_v6, _v7, _v7_12,
    #    _v7_pre12).  Single-version types (mikrotik_api) are unaffected.
    Puppet::Type.eachtype do |type|
      dp = type.instance_variable_get(:@defaultprovider)
      if dp && dp.respond_to?(:name) && dp.name.to_s.start_with?('mikrotik_api_v')
        type.instance_variable_set(:@defaultprovider, nil)
      end
    end
  rescue => e
    Puppet.debug("Mikrotik: failed to reset version caches: #{e.message}")
  end
end