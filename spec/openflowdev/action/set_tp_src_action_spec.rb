require 'spec_helper'
require 'openflowdev/actions/set_tp_src_action'

RSpec.describe SetTpSrcAction do
  describe 'argument validation' do
    it 'requires a port for instantiation' do
      expect { SetTpSrcAction.new(order: 0) }.to raise_error(ArgumentError,
        "Port (port) required")
    end
  end
end