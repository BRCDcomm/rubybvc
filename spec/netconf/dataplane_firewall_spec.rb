require 'spec_helper'
require 'netconfdev/vrouter/dataplane_firewall'

RSpec.describe DataplaneFirewall do
  describe 'argument validations' do
    it 'requires an interface name for instantiation' do
      expect { DataplaneFirewall.new }.to raise_error(ArgumentError,
        "Interface Name (interface_name) required")
    end
    
    it 'requires at least one firewall to be named for instantiation' do
      expect { DataplaneFirewall.new(interface_name: 'name') }.
        to raise_error(ArgumentError,"At least one firewall name "\
            "(in_firewall_name, out_firewall_name) required")
    end
  end
end