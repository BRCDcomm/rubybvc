require 'spec_helper'
require 'openflowdev/flow_entry'

RSpec.describe FlowEntry do
  describe 'argument validation' do
    it 'requires a flow ID for instantiation' do
      expect { FlowEntry.new }.to raise_error(ArgumentError,
        "Flow ID (flow_id) required")
    end
    
    it 'requires a flow priority for instantiation' do
      expect { FlowEntry.new(flow_id: 2) }.to raise_error(ArgumentError,
        "Flow Priority (flow_priority) required")
    end
    
    it 'requires an intruction to be of class Instruction' do
      flow_entry = FlowEntry.new(flow_id: 1, flow_priority: 1010)
      expect { flow_entry.add_instruction({'manual' => 'hash'}) }.
        to raise_error(ArgumentError, "Instruction must be of type 'Instruction'")
    end
    
    it 'requires a match to be of class Match' do
      flow_entry = FlowEntry.new(flow_id: 2, flow_priority: 1011)
      expect { flow_entry.add_match({'match' => 'hash'}) }.to raise_error(ArgumentError,
        "Match must be of type 'Match'")
    end
  end
end