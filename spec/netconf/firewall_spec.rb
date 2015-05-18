require 'spec_helper'
require 'netconfdev/vrouter/firewall'

RSpec.describe Firewall do
  describe 'argument validation' do
    it 'requires rules on instantiation' do
      expect { Firewall.new }.to raise_error(ArgumentError,
        "Rules (rules) required")
    end
    
    it 'requires rules to be an instance of Rules' do
      expect {Firewall.new(rules: [{:id => 'manual'}]) }.to raise_error(ArgumentError,
        "Rules (rules) must be instance of 'Rules'")
    end
  end
end