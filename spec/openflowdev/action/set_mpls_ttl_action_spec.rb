require 'spec_helper'
require 'openflowdev/actions/set_mpls_ttl_action'

RSpec.describe SetMplsTTLAction do
  describe 'argument validation' do
    it 'requires a value for MPLS TTL for instantiation' do
      expect { SetMplsTTLAction.new }.to raise_error(ArgumentError,
        "MPLS TTL (mpls_ttl) required")
    end
  end
end