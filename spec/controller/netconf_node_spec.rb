require 'spec_helper'
require 'controller/netconf_node'

RSpec.describe NetconfNode do
  let(:controller) { Controller.new(ip_addr: '1.2.3.4', admin_name: 'username',
    admin_password: 'password') }
  describe 'argument validations' do
    it 'requires a controller for instantiation' do
      expect { NetconfNode.new(ip_addr: '4.3.2.1') }.to raise_error(ArgumentError,
        "Controller (controller) required")
    end
    
    it 'requires a name for instantiation' do
      expect { NetconfNode.new(ip_addr: '4.3.2.1', controller: controller) }.
        to raise_error(ArgumentError, "Name (name) required")
    end
    
    it 'requires an ip address for instantiation' do
      expect { NetconfNode.new(controller: controller, name: 'test') }.
        to raise_error(ArgumentError, "IP Address (ip_addr) required")
    end
    
    it 'requires a port number for instantiation' do
      expect { NetconfNode.new(name: 'test', ip_addr: '4.3.2.1',
          controller: controller) }.
        to raise_error(ArgumentError, "Port Number (port_number) required")
    end
    
    it 'requires an admin username for instantiation' do
      expect { NetconfNode.new(ip_addr: '4.3.2.1', controller: controller,
          name: 'test', port_number: 800) }.to raise_error(ArgumentError,
        "Admin Username (admin_name) required")
    end
    
    it 'requires an admin password for instantiation' do
      expect { NetconfNode.new(ip_addr: '4.3.2.1', controller: controller,
          name: 'test', port_number: 800, admin_name: 'username') }.
        to raise_error(ArgumentError, "Admin Password (admin_password) required")
    end
    
    it 'requires controller to be an instance of "Controller"' do
      expect { NetconfNode.new(ip_addr: '4.3.2.1', controller: "controller",
          name: 'test', port_number: 800, admin_name: 'username',
          admin_password: 'password') }.
        to raise_error(ArgumentError, "Controller (controller) must be instance of 'Controller'")
    end
  end
end