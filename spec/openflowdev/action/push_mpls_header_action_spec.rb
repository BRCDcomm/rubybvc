require 'spec_helper'
require 'openflowdev/actions/push_mpls_header_action'

RSpec.describe PushMplsHeaderAction do
  describe 'argument validation' do
    it 'requires an ethernet type to be provided for instantiation' do
      expect { PushMplsHeaderAction.new }.to raise_error(ArgumentError,
        "Ethernet Type (eth_type) required")
    end
  end
end