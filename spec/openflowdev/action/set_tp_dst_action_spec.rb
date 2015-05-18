require 'spec_helper'
require 'openflowdev/actions/set_tp_dst_action'

RSpec.describe SetTpDstAction do
  describe 'argument validation' do
    it 'requires a port for instantiation' do
      expect { SetTpDstAction.new(order: 0) }.to raise_error(ArgumentError,
        "Port (port) required")
    end
  end
end