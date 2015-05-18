require 'spec_helper'
require 'openflowdev/actions/output_action'

RSpec.describe OutputAction do
  describe 'arugment validations' do
    it 'requires a port value for instantiation' do
      expect { OutputAction.new }.to raise_error(ArgumentError,
        "Port (port) required")
    end
  end
end