require 'spec_helper'
require 'openflowdev/actions/set_vlan_id_action'

RSpec.describe SetVlanIdAction do
  describe 'argument validation' do
    it 'requires a VLAN ID to be defined for instantiation' do
      expect { SetVlanIdAction.new(order: 0) }.to raise_error(ArgumentError,
        "VLAN ID (vlan_id) required")
    end
  end
end