require 'spec_helper'
require 'utils/netconf_response'

RSpec.describe NetconfResponse do
  it 'produces a human readable message for all status codes' do
    NetconfResponseStatus.constants.each do |status|
      response = NetconfResponse.new(NetconfResponseStatus.const_get(status))
      expect(response.message).not_to be_nil
    end
  end
end