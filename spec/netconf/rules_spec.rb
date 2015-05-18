require 'spec_helper'
require 'netconfdev/vrouter/rules'

RSpec.describe Rules do
  describe 'argument validation' do
    it 'requires a name for instantiation' do
      expect { Rules.new }.to raise_error(ArgumentError, "Name (name) required")
    end
    
    it 'requires any added rules to be instances of "Rule"' do
      rules = Rules.new(name: 'test-rule')
      expect { rules.add_rule("rule") }.to raise_error(ArgumentError,
        "Rule must be instance of 'Rule'")
    end
  end
end