require 'spec_helper'
require 'openflowdev/actions/set_vlan_pcp_action'

RSpec.describe SetVlanPCPAction do
  describe 'argument validation' do
    it 'requires a VLAN PCP to be defined for instantiation' do
      expect { SetVlanPCPAction.new(order: 0) }.to raise_error(ArgumentError,
        "VLAN PCP (vlan_pcp) required")
    end
  end
end