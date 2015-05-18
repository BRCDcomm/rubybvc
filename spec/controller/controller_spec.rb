require 'spec_helper'
require 'controller/controller'

RSpec.describe Controller do
  let(:controller) { Controller.new(ip_addr: '1.2.3.4', port_number: '1234',
      admin_name: 'username', admin_password: 'password')}
  
  describe 'successful response' do
    it 'gets a list of schemas for a particular node' do
      node_name = "that-node"
      schemas = {:schemas => {:schema => [{:identifier => 'schema-identifier',
          :version => '2015-04-10', :format => 'ietf-netconf-monitoring:yang',
          :location => ['NETCONF'],
          :namespace => 'urn:opendaylight:schema:namespace'}]}}.to_json
      WebMock.stub_request(:get,
        ("http://#{controller.username}:#{controller.password}@" \
          "#{controller.ip}:#{controller.port}/restconf/operational/" \
          "opendaylight-inventory:nodes/node/#{node_name}/"\
          "yang-ext:mount/ietf-netconf-monitoring:netconf-state/schemas")).
        to_return(:body => schemas)

      response = controller.get_schemas(node_name)
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(JSON.parse(schemas)["schemas"]["schema"])
    end

    it 'gets a particular schema' do
      node_name = "that-node"
      schema_id = "name-of-schema"
      schema_version = "2015-04-10"

      schema = {"get-schema" => {:output => {:data => "some yang data"}}}.to_json
      WebMock.stub_request(:post, 
        "http://#{controller.username}:#{controller.password}@" \
        "#{controller.ip}:#{controller.port}/restconf/operations/" \
        "opendaylight-inventory:nodes/node/#{node_name}/yang-ext:mount/" \
        "ietf-netconf-monitoring:get-schema").with(:body =>
        hash_including({:input => {:identifier => schema_id,
            :version => schema_version, :format => "yang"}})).
      to_return(:body => schema)

      response = controller.get_schema(node_name, id: schema_id,
        version: schema_version)
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(JSON.parse(schema)['get-schema']['output']['data'])
    end

    it 'gets a list of service provider applications' do
      services = {:services => {:service => [{:type => "service-type",
              :instance => [{:name => "instance-name",
                  :provider => 'instance provider'}]}]}}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@" \
        "#{controller.ip}:#{controller.port}/restconf/config/"\
        "opendaylight-inventory:nodes/node/controller-config/yang-ext:mount/"\
        "config:services").to_return(:body => services)

      response = controller.get_service_providers_info
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(JSON.parse(services)['services']['service'])
    end

    it 'gets info for a particular service provider' do
      service_name = "my-service"

      service_info = {:service => [{:type => 'service-type', :instance =>
        [{:name => 'instance-name', :provider => 'instance provider'}]}]}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/config/"\
        "opendaylight-inventory:nodes/node/controller-config/yang-ext:mount/"\
        "config:services/service/#{service_name}").to_return(:body => service_info)

      response = controller.get_service_provider_info(service_name)
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(JSON.parse(service_info)['service'])
    end

    it 'shows a list of all NETCONF operations that are supported' do
      node_name = "that-node"

      operations = {:operations => {:operation_name => [nil]}}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operations/"\
        "opendaylight-inventory:nodes/node/#{node_name}/yang-ext:mount").
      to_return(:body => operations)

      response = controller.get_netconf_operations(node_name)
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(JSON.parse(operations)['operations'])
    end

    it 'shows the operational state of all configuration modules' do
      states = {"modules" => {"module"=> [{"type" => "the-type",
              "name" => "name","specific-value" => "Wed 2015.04.15 at 11:04:14 AM EDT\\
        FROM_SWITCH_ENQUEUED: no activity detected\\\n"}]}}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/controller-config/yang-ext:mount/"\
        "config:modules").to_return(:body => states)

      response = controller.get_all_modules_operational_state
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(JSON.parse(states)['modules']['module'])
    end

    it 'shows the operational state of a particular configuration module' do
      module_type = "module-type"
      module_name = "module-name"
      state = {:module => [{:type => module_type, :name => module_name,
          'module-specific-propery' => 'module-specific value'}]}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/controller-config/yang-ext:mount/"\
        "config:modules/module/#{module_type}/#{module_name}").
      to_return(:body => state)

      response = controller.get_module_operational_state(type: module_type,
        name: module_name)
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(JSON.parse(state)['module'])
    end

    it 'shows the sessions running on a node' do
      node_name = "that-node"
      sessions = {:sessions => {:session => [{:session_id => 1,
              :username => 'admin', :source_host => '127.0.0.1'}]}}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@" \
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{node_name}/yang-ext:mount"\
        "/ietf-netconf-monitoring:netconf-state/sessions").
      to_return(:body => sessions)

      response = controller.get_sessions_info(node_name)
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(JSON.parse(sessions)['sessions'])
    end

    it 'shows notification event streams registered on the controller' do
      streams = {:streams => {}}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/streams").
      to_return(:body => streams)

      response = controller.get_streams_info
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(JSON.parse(streams)['streams'])
    end

    it 'shows the configured nodes' do
      nodes = {:nodes => {:node => [{:id => 'node-id'}]}}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/config/"\
        "opendaylight-inventory:nodes").to_return(:body => nodes)

      response = controller.get_all_nodes_in_config
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq([JSON.parse(nodes)['nodes']['node'][0]['id']])
    end
    
    it 'shows the configured NETCONF nodes' do
      nodes = {:nodes => {:node => [{:id => 'node-id'},
          {:id => 'openflow:1'}]}}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/config/"\
        "opendaylight-inventory:nodes").to_return(:body => nodes)

      response = controller.get_netconf_nodes_in_config
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq([JSON.parse(nodes)['nodes']['node'][0]['id']])
    end
    
    it 'shows the configured NETCONF nodes connection status' do
      node_id = "node-id"
      of_node_id = "openflow:1"
      connection_status = {:nodes => {:node => [{:id => node_id,
            'netconf-node-inventory:connected' => true},
          {:id => of_node_id}]}}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes").to_return(:body => connection_status)

      response = controller.get_netconf_nodes_conn_status
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq([{:node => node_id, :connected => true}])
    end
    
    it 'gets a list of all operational nodes' do
      nodes = {:nodes => {:node => [{:id => 'node-id'}]}}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes").to_return(:body => nodes)
    
      response = controller.get_nodes_operational_list
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq([JSON.parse(nodes)['nodes']['node'][0]['id']])
    end
    
    it 'shows the configured openflow nodes' do
      nodes = {:nodes => {:node => [{:id => "openflow:1"},
            {:id => "node-id"}]}}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes").to_return(:body => nodes)
    
      response = controller.get_openflow_nodes_operational_list
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(["openflow:1"])
    end

    it 'adds a node' do
      new_node = NetconfNode.new(controller: controller, name: 'test-node',
        ip_addr: '1.2.3.5', port_number: 1234, admin_name: 'node-admin',
        admin_password: 'node-pass')
      
      mock_http = double('http')
      response = double('response')
      expect(Net::HTTP).to receive(:start).and_yield mock_http
      expect(response).to receive(:code).and_return("204")
      expect(response).to receive(:body).at_least(:once).and_return nil
      # want to check post body; webmock doesn't have the best partial match
      # and the post body is a giant xml document
      expect(mock_http).to receive(:request) do |post_request|
        @uri = post_request.uri
        @body = post_request.body
        expect(post_request['Content-Type']).to eq('application/xml')
        expect(post_request['Accept']).to eq('application/xml')
        response
      end

      response = controller.add_netconf_node(new_node)

      expect(@body).to include(new_node.name)
      expect(@body).to include(new_node.ip)
      expect(@body).to include(new_node.port.to_s)
      expect(@body).to include(new_node.username)
      expect(@body).to include(new_node.password)
      expect(response.status).to eq(NetconfResponseStatus::OK)
    end

    it 'checks a node configuration' do
      node_id = "node-id"
      config_status = {:node => [{:id => node_id}]}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/config/"\
        "opendaylight-inventory:nodes/node/#{node_id}").
      to_return(:body => config_status)

      response = controller.check_node_config_status(node_id)
      expect(response.status).to eq(NetconfResponseStatus::NODE_CONFIGURED)
    end
    
    it 'returns information on a node' do
      node_id = "node-id"
      info = {:node => {:id => node_id}}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{node_id}").to_return(:body => info)
    
      response = controller.get_node_info(node_id)
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(JSON.parse(info)['node'])
    end

    it 'shows connections status for all nodes' do
      node_id = "node-id"
      of_node_id = "openflow:1"
      connection_status = {:nodes => {:node => [{:id => node_id,
            'netconf-node-inventory:connected' => true},
          {:id => of_node_id}]}}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes").to_return(:body => connection_status)

      response = controller.get_all_nodes_conn_status
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to include({:node => node_id, :connected => true})
      expect(response.body).to include({:node => of_node_id, :connected => true})
    end

    it 'shows connection status for a particular node when node connected' do
      node_id = "node-id"
      connection_status = {:node => [{:id => node_id,
            'netconf-node-inventory:connected' => true}]}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{node_id}").
      to_return(:body => connection_status)

      response = controller.check_node_conn_status(node_id)
      expect(response.status).to eq(NetconfResponseStatus::NODE_CONNECTED)
    end

    it 'shows connection status for a particular node when node disconnected' do
      node_id = "node-id"
      connection_status = {:node => [{:id => node_id}]}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{node_id}").
      to_return(:body => connection_status)

      response = controller.check_node_conn_status(node_id)
      expect(response.status).to eq(NetconfResponseStatus::NODE_DISCONNECTED)
    end

    it 'removes a node' do
      node = NetconfNode.new(controller: controller, name: 'test-node',
        ip_addr: '1.2.3.5', port_number: 1234, admin_name: 'node-admin',
        admin_password: 'node-pass')
      WebMock.stub_request(:delete,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/config/"\
        "opendaylight-inventory:nodes/node/controller-config/yang-ext:mount/"\
        "config:modules/module/"\
        "odl-sal-netconf-connector-cfg:sal-netconf-connector/#{node.name}")

      response = controller.delete_netconf_node(node)
      expect(response.status).to eq(NetconfResponseStatus::OK)
    end
  end
  
  describe 'erroneous response' do
    it 'returns a CONN_ERROR status when no response is returned' do
      node_name = "that-node"
      address = "http://#{controller.ip}:#{controller.port}/restconf/operational/"\
          "opendaylight-inventory:nodes/node/#{node_name}/"\
          "yang-ext:mount/ietf-netconf-monitoring:netconf-state/schemas"
      # use mock_http because webmock can't return nil response
      mock_http = double('http')
      expect(Net::HTTP).to receive(:start).and_yield mock_http
      expect(mock_http).to receive(:request) do |get_request|
        expect(get_request.uri.to_s).to eq(address)
        expect(get_request['Authorization']).not_to be_nil
        nil
      end

      response = controller.get_schemas(node_name)
      expect(response.status).to eq(NetconfResponseStatus::CONN_ERROR)
    end
    
    it 'returns a CTRL_INTERNAL_ERROR status when no body is returned' do
      node_name = "that-node"
      WebMock.stub_request(:get,
        ("http://#{controller.username}:#{controller.password}@" \
          "#{controller.ip}:#{controller.port}/restconf/operational/" \
          "opendaylight-inventory:nodes/node/#{node_name}/"\
          "yang-ext:mount/ietf-netconf-monitoring:netconf-state/schemas")).
        to_return(:body => nil)

      response = controller.get_schemas(node_name)
      expect(response.status).to eq(NetconfResponseStatus::CTRL_INTERNAL_ERROR)
    end
    
    it 'returns a DATA_NOT_FOUND status when the body does not contain the expected data' do
      node_name = "that-node"
      WebMock.stub_request(:get,
        ("http://#{controller.username}:#{controller.password}@" \
          "#{controller.ip}:#{controller.port}/restconf/operational/" \
          "opendaylight-inventory:nodes/node/#{node_name}/"\
          "yang-ext:mount/ietf-netconf-monitoring:netconf-state/schemas")).
        to_return(:body => {}.to_json)

      response = controller.get_schemas(node_name)
      expect(response.status).to eq(NetconfResponseStatus::DATA_NOT_FOUND)
    end
    
    it 'returns a HTTP_ERROR status when an error code is returned' do
      node_name = "that-node"
      WebMock.stub_request(:get,
        ("http://#{controller.username}:#{controller.password}@" \
          "#{controller.ip}:#{controller.port}/restconf/operational/" \
          "opendaylight-inventory:nodes/node/#{node_name}/"\
          "yang-ext:mount/ietf-netconf-monitoring:netconf-state/schemas")).
        to_return(:status => 404)

      response = controller.get_schemas(node_name)
      expect(response.status).to eq(NetconfResponseStatus::HTTP_ERROR)
    end
    
    it 'returns a NODE_NOT_FOUND status when 404 is returned when checking connection status' do
      node_id = "node-id"
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{node_id}").
      to_return(:status => 404)

      response = controller.check_node_conn_status(node_id)
      expect(response.status).to eq(NetconfResponseStatus::NODE_NOT_FOUND)
    end
  end
  
  describe 'argument validations' do
    it 'requires an IP address for instantiation' do
      expect { Controller.new }.to raise_error(ArgumentError,
        "IP Address (ip_addr) required")
    end
    
    it 'requires admin username for instantiation' do
      expect { Controller.new(ip_addr: '1.2.3.4') }.to raise_error(ArgumentError,
        "Admin Username (admin_name) required")
    end
    
    it 'requires admin password for instantiation' do
      expect { Controller.new(ip_addr: '1.2.3.4', admin_name: 'test') }.
        to raise_error(ArgumentError, "Admin Password (admin_password) required")
    end
    
    it 'requires an identifier for a schema lookup' do
      node_name = "name"
      expect { controller.get_schema(node_name) }.to raise_error(ArgumentError,
        "Identifier (id) required")
    end
    
    it 'requires a version for a schema lookup' do
      node_name = "name"
      expect { controller.get_schema(node_name, id: 'node-id') }.
        to raise_error(ArgumentError, "Version (version) required")
    end
    
    it 'requires a type for checking the operational state of a module' do
      expect { controller.get_module_operational_state }.to raise_error(ArgumentError,
        "Type (type) required")
    end
    
    it 'requires a name for checking the operational state of a module' do
      expect { controller.get_module_operational_state(type: 'module-type') }.
        to raise_error(ArgumentError, "Name (name) required")
    end
    
    it 'requires a Node (or subclass) to be used as an argument for obtaining URIs' do
      expect { controller.get_node_operational_uri('name') }.to raise_error(ArgumentError,
        "Node (node) must be a 'Node' object or a 'Node' subclass object")
      
      expect { controller.get_node_config_uri('name') }.to raise_error(ArgumentError,
        "Node (node) must be a 'Node' object or a 'Node' subclass object")
      
      expect { controller.get_ext_mount_config_uri('name') }.to raise_error(ArgumentError,
        "Node (node) must be a 'Node' object or a 'Node' subclass object")
    end
  end
end