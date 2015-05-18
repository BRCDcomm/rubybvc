require 'spec_helper'
require 'openflowdev/action_output'

RSpec.describe ActionOutput do
  describe '#update' do
    it 'updates fields provided' do
      ao = ActionOutput.new
      ao.update(port: 1)
      expect(ao.port).to eq(1)

      ao.update(length: 255)
      expect(ao.length).to eq(255)
      expect(ao.port).to eq(1)

      ao.update(order: 1)
      expect(ao.order).to eq(1)
      expect(ao.length).to eq(255)
      expect(ao.port).to eq(1)
    end
  end
  
  describe '#to_s' do
    it 'includes the port and length when port is set to "CONTROLLER"' do
      ao = ActionOutput.new(port: "CONTROLLER", length: 255)
      expect(ao.to_s).to eq("CONTROLLER:255")
    end
    
    it 'include the type an port when port is not set to "CONTROLLER"' do
      ao = ActionOutput.new(port: 1, length: 255)
      expect(ao.to_s).to eq("output:1")
    end
  end
end