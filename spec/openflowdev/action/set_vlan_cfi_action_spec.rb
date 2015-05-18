require 'spec_helper'
require 'openflowdev/actions/set_vlan_cfi_action'

RSpec.describe SetVlanCfiAction do
  describe 'argument validation' do
    it 'requires a VLAN CFI to be defined for instantiation' do
      expect { SetVlanCfiAction.new(order: 0) }.to raise_error(ArgumentError,
        "VLAN CFI (vlan_cfi) required")
    end
  end
end