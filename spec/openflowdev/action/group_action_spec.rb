require 'spec_helper'
require 'openflowdev/actions/group_action'

RSpec.describe GroupAction do
  describe 'argument validation' do
    it 'requires a group for initialization' do
      expect { GroupAction.new(order: 0) }.to raise_error(ArgumentError,
        "Group (group) required")
    end

    it 'requires a group id for initialization' do
      expect { GroupAction.new(order: 0, group: 'my-group') }.
        to raise_error(ArgumentError, "Group ID (group_id) required")
    end
  end
end