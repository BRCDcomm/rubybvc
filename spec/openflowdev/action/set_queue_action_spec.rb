require 'spec_helper'
require 'openflowdev/actions/set_queue_action'

RSpec.describe SetQueueAction do
  describe 'argument validation' do
    it 'requires a queue for initialization' do
      expect { SetQueueAction.new(order: 0) }.to raise_error(ArgumentError,
        "Queue (queue) required")
    end

    it 'requires a group id for initialization' do
      expect { SetQueueAction.new(order: 0, queue: 'my-queue') }.
        to raise_error(ArgumentError, "Queue ID (queue_id) required")
    end
  end
end