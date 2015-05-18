require 'spec_helper'
require 'netconfdev/vrouter/rule'

RSpec.describe Rule do
  describe 'argument validation' do
    it 'requires a rule number to be defined for instantiation' do
      expect { Rule.new }.to raise_error(ArgumentError,
        "Rule number (rule_number) required")
    end
    
    it 'requires an action to be defined for instantiation' do
      expect { Rule.new(rule_number: 1) }.to raise_error(ArgumentError,
        "Action (action) required")
    end    
  end
end