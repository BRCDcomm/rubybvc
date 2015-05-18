require 'spec_helper'
require 'openflowdev/actions/set_dl_src_action'

RSpec.describe SetDlSrcAction do
  describe 'argument validation' do
    it 'requires a mac address for instantiation' do
      expect { SetDlSrcAction.new(order: 0) }.to raise_error(ArgumentError,
        "MAC Address (mac_addr) required")
    end
  end
end