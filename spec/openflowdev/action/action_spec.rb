require 'spec_helper'
require 'openflowdev/actions/action'

RSpec.describe Action do
  describe 'argument validation' do
    it 'requires order to be defined for instantiation' do
      expect { Action.new }.to raise_error(ArgumentError, "Order (order) required")
    end
  end
end