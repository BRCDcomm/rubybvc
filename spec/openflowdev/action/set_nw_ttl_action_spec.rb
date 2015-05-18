require 'spec_helper'
require 'openflowdev/actions/set_nw_ttl_action'

RSpec.describe SetNwTTLAction do
  describe 'argument validation' do
    it 'requires a value for MPLS TTL for instantiation' do
      expect { SetNwTTLAction.new }.to raise_error(ArgumentError,
        "IP TTL (ip_ttl) required")
    end
  end
end