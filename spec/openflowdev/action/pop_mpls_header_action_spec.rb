require 'spec_helper'
require 'openflowdev/actions/pop_mpls_header_action'

RSpec.describe PopMplsHeaderAction do
  describe 'argument validation' do
    it 'requires an ethernet type to be provided for instantiation' do
      expect { PopMplsHeaderAction.new }.to raise_error(ArgumentError,
        "Ethernet Type (eth_type) required")
    end
  end
end