require 'spec_helper'
require 'openflowdev/instruction'

RSpec.describe Instruction do
  describe 'argument validation' do
    it 'requires an order value for instantiation' do
      expect { Instruction.new }.to raise_error(ArgumentError,
        "Instruction Order (instruction_order) required")
    end
    
    it 'requires a new applied action to be a subclass of Action' do
      instruction = Instruction.new(instruction_order: 0)
      expect { instruction.add_apply_action({'key' => 'value'}) }.
        to raise_error(ArgumentError, "Action must be a subclass of 'Action'")
    end
  end
end