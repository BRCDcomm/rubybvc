require 'spec_helper'
require 'openflowdev/actions/drop_action'
require 'openflowdev/of_switch'

RSpec.describe OFSwitch do
  let(:controller) { Controller.new(ip_addr: '1.2.3.4', port_number: 1234,
      admin_name: 'username', admin_password: 'password')}
  let(:switch) { OFSwitch.new(controller: controller, name: 'switch-name', dpid: 'mac')}
  
  describe 'successful requests' do
    it 'gets switch info' do
      config_status = {:node => [{:id => switch.name,
          'flow-node-inventory:manufacturer' => "manufacturer",
          'flow-node-inventory:serial-number' => "1234",
          'flow-node-inventory:software' => '1.1',
          'flow-node-inventory:hardware' => 'Open vSwitch',
          'flow-node-inventory:description' => "A description"}]}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{switch.name}").
      to_return(:body => config_status)

      response = switch.get_switch_info
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq({"manufacturer" => "manufacturer",
        "serial-number" => '1234', "software" => "1.1",
        "hardware" => "Open vSwitch", "description" => "A description"})
    end

    it 'gets features list' do
      config_status = {:node => [{:id => switch.name,
          'flow-node-inventory:switch-features' => {:max_tables => 123,
          :max_buffers => 123, :capabilities => [
          'flow-node-inventory:flow-feature-capability-feature-1']}}]}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{switch.name}").
      to_return(:body => config_status)

      response = switch.get_features_info
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq({"max_tables" => 123, "max_buffers" => 123,
        'capabilities' => ["feature-1"]})
    end

    it 'gets a port list' do
      config_status = {:node => [{:id => switch.name,
          'node-connector' => [{'flow-node-inventory:port-number' => "1"}]}]}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{switch.name}").
      to_return(:body => config_status)

      response = switch.get_ports_list
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(["1"])
    end

    it 'gets brief info on ports' do
      config_status = {:node => [{:id => switch.name,
          'node-connector' => [{:id => "port-id",
          'flow-node-inventory:port-number' => "1",
          'flow-node-inventory:name' => "name",
          'flow-node-inventory:hardware-address' => "11:22:33:44:55:66",
          'flow-node-inventory:current-feature' => 'feature'}]}]}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{switch.name}").
      to_return(:body => config_status)

      response = switch.get_ports_brief_info
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq([{'id' => "port-id", 'number' => '1',
          'name' => 'name', 'mac-address' => '11:22:33:44:55:66',
          'current-feature' => "FEATURE"}])
    end

    it 'gets brief info on a particular port' do
      port_number = "1"
      port_details = {'node-connector' => [{:id => 'port-id',
          :port_detail_key => 'port-detail-value'}]}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{switch.name}/node-connector/"\
        "#{switch.name}:#{port_number}").to_return(:body => port_details)

      response = switch.get_port_detail_info(port_number)
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(JSON.parse(port_details)['node-connector'][0])
    end

    it 'adds a flow' do
      flow_entry = FlowEntry.new(flow_table_id: 1, flow_id: 2,
        flow_priority: 1000)
      instruction = Instruction.new(instruction_order: 0)
      action = DropAction.new(order: 0)
      instruction.add_apply_action(action)
      flow_entry.add_instruction(instruction)    
      match = Match.new(eth_type: 2048, ipv4_destination: "10.11.12.13/24")
      flow_entry.add_match(match)

      WebMock.stub_request(:put,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/config/"\
        "opendaylight-inventory:nodes/node/#{switch.name}/"\
        "table/#{flow_entry.table_id}/flow/#{flow_entry.id}").
      with(:body => flow_entry.to_hash.to_json).
      to_return(:body => flow_entry.to_hash.to_json)

      response = switch.add_modify_flow(flow_entry)
      expect(response.status).to eq(NetconfResponseStatus::OK)
    end

    it 'gets a particular configured flow' do
      table_id = "1"
      flow_id = "2"

      configured_flow = {:id => flow_id, :table_id => table_id,
        :other_configuration => "other_value"}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/config/"\
        "opendaylight-inventory:nodes/node/#{switch.name}/"\
        "table/#{table_id}/flow/#{flow_id}").to_return(:body => configured_flow)

      response = switch.get_configured_flow(table_id: table_id, flow_id: flow_id)
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(JSON.parse(configured_flow))
    end
    
    it 'deletes a particular flow' do
      table_id = "1"
      flow_id = "2"
      
      WebMock.stub_request(:delete,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/config/"\
        "opendaylight-inventory:nodes/node/#{switch.name}/"\
        "table/#{table_id}/flow/#{flow_id}")
    
      response = switch.delete_flow(table_id: table_id, flow_id: flow_id)
      expect(response.status).to eq(NetconfResponseStatus::OK)
    end

    it 'gets operational flows' do
      table_id = 0
      flows = {'flow-node-inventory:table' => [{:id => table_id, 
          :flow => [{:flow_stat_1 => "flow value 1"}]}]}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{switch.name}/"\
        "flow-node-inventory:table/#{table_id}").to_return(:body => flows)
      
      response = switch.get_operational_flows(table_id: table_id)
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(JSON.parse(flows)['flow-node-inventory:table'][0]['flow'])
    end
    
    it 'gets configured flows' do
      table_id = 0
      flows = {'flow-node-inventory:table' => [{:id => table_id, 
          :flow => [{:flow_stat_1 => "flow value 1"}]}]}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/config/"\
        "opendaylight-inventory:nodes/node/#{switch.name}/"\
        "flow-node-inventory:table/#{table_id}").to_return(:body => flows)
      
      response = switch.get_configured_flows(table_id: table_id)
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body).to eq(JSON.parse(flows)['flow-node-inventory:table'][0]['flow'])
    end
    
    it 'returns the operational flows in OVS syntax' do
      table_id = 0
      flows = {'flow-node-inventory:table' => [{:id => table_id, 
          :flow => [{'opendaylight-flow-statistics:flow-statistics' =>
            {'byte-count' => 11, :duration => {:nanosecond => 128000000, 
              :second => 22}, 'packet-count' => 33}, :table_id => table_id,
          :priority => 1, :cookie => 1234, :match =>
            {'in-port' => "#{switch.name}:5", 'vlan-match' => {'vlan-id' =>
                {'vlan-id' => 1}, 'vlan-pcp' => 2}, 'ethernet-match' =>
              {'ethernet-type' => {:type => 10000}, 'ethernet-source' =>
                {:address => '1.2.3.4'}, 'ethernet-destination' =>
                {:address => '4.3.2.1'}}, 'ip-match' => {'ip-protocol' => 321},
            'tcp-source-port' => '1234', 'ipv4-source' => '2.3.4.5',
            'ipv4-destination' => '5.4.3.2'},
          :instructions => {:instruction => [{'apply-actions' => {:action =>
              [{:order => 0, 'output-action' => {'output-node-connector' =>
                "controller"}}]}}]}, 'idle-timeout' => 20,
          'hard-timeout' => 600}]}]}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{switch.name}/"\
        "flow-node-inventory:table/#{table_id}").to_return(:body => flows)
    
      response = switch.get_operational_flows_ovs_syntax(table_id: table_id)
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body[0]).to have_key('cookie')
      expect(response.body[0]).to have_key('duration')
      expect(response.body[0]).to have_key('table')
      expect(response.body[0]).to have_key('n_packets')
      expect(response.body[0]).to have_key('n_bytes')
      expect(response.body[0]).to have_key('priority')
      expect(response.body[0]).to have_key('in_port')
      expect(response.body[0]).to have_key('actions')
      expect(response.body[0]).to have_key('idle_timeout')
      expect(response.body[0]).to have_key('hard_timeout')
      expect(response.body[0]).to have_key('dl_vlan')
      expect(response.body[0]).to have_key('dl_vlan_pcp')
      expect(response.body[0]).to have_key('dl_type')
      expect(response.body[0]).to have_key('dl_src')
      expect(response.body[0]).to have_key('dl_dst')
      expect(response.body[0]).to have_key('nw_proto')
      expect(response.body[0]).to have_key('tp_src')
      expect(response.body[0]).to have_key('nw_src')
      expect(response.body[0]).to have_key('nw_dst')
    end
    
    it 'returns the configured flows in OVS syntax' do
      table_id = 0
      flows = {'flow-node-inventory:table' => [{:id => table_id, 
          :flow => [{'opendaylight-flow-statistics:flow-statistics' =>
            {'byte-count' => 11, :duration => {:nanosecond => 128000000, 
              :second => 22}, 'packet-count' => 33}, :table_id => table_id,
          :priority => 1, :cookie => 1234, :match => {'in-port' => "#{switch.name}:5"},
          :instructions => {:instruction => [{'apply-actions' => {:action =>
              [{:order => 0, 'output-action' => {'output-node-connector' =>
                "controller"}}]}}]}}]}]}.to_json
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/config/"\
        "opendaylight-inventory:nodes/node/#{switch.name}/"\
        "flow-node-inventory:table/#{table_id}").to_return(:body => flows)
    
      response = switch.get_configured_flows_ovs_syntax(table_id: table_id)
      expect(response.status).to eq(NetconfResponseStatus::OK)
      expect(response.body[0]).to have_key('cookie')
      expect(response.body[0]).to have_key('duration')
      expect(response.body[0]).to have_key('table')
      expect(response.body[0]).to have_key('n_packets')
      expect(response.body[0]).to have_key('n_bytes')
      expect(response.body[0]).to have_key('priority')
      expect(response.body[0]).to have_key('in_port')
      expect(response.body[0]).to have_key('actions')
    end
  end
  
  describe 'erroneous requests' do
    it 'returns a CONN_ERROR status when no response is returned' do
      address = "http://#{controller.ip}:#{controller.port}/restconf/"\
        "operational/opendaylight-inventory:nodes/node/#{switch.name}"
      mock_http = double('http')
      expect(Net::HTTP).to receive(:start).and_yield mock_http
      expect(mock_http).to receive(:request) do |get_request|
        expect(get_request.uri.to_s).to eq(address)
        expect(get_request['Authorization']).not_to be_nil
        nil
      end

      response = switch.get_switch_info
      expect(response.status).to eq(NetconfResponseStatus::CONN_ERROR)
    end
    
    it 'returns a CTRL_INTERNAL_ERROR status when no body is returned' do
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{switch.name}").
      to_return(:body => nil)

      response = switch.get_switch_info
      expect(response.status).to eq(NetconfResponseStatus::CTRL_INTERNAL_ERROR)
    end
    
    it 'returns a DATA_NOT_FOUND status when the body does not contain the expected response' do
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{switch.name}").
      to_return(:body => {}.to_json)

      response = switch.get_switch_info
      expect(response.status).to eq(NetconfResponseStatus::DATA_NOT_FOUND)
    end
    
    it 'retuns an HTTP_ERROR status when an error code is returned' do
      WebMock.stub_request(:get,
        "http://#{controller.username}:#{controller.password}@"\
        "#{controller.ip}:#{controller.port}/restconf/operational/"\
        "opendaylight-inventory:nodes/node/#{switch.name}").
      to_return(:status => 400)

      response = switch.get_switch_info
      expect(response.status).to eq(NetconfResponseStatus::HTTP_ERROR)
    end
  end
  
  describe 'argument validation' do
    it 'requires a controller on instantiation' do
      expect { OFSwitch.new }.to raise_error(ArgumentError,
        "Controller (controller) required")
    end
    
    it 'requires a name on instantiation' do
      expect { OFSwitch.new(controller: controller) }.to raise_error(ArgumentError,
        "Name (name) required")
    end
    
    it 'requires a table id for retrieving a configured flow' do
      expect { switch.get_configured_flow }.to raise_error(ArgumentError,
        "Table ID (table_id) required")
    end
    
    it 'requires a flow id for retrieving a configured flow' do
      expect { switch.get_configured_flow(table_id: 0) }.
        to raise_error(ArgumentError, "Flow ID (flow_id) required")
    end
    
    it 'requires a table id for deleting a configured flow' do
      expect { switch.delete_flow }.to raise_error(ArgumentError,
        "Table ID (table_id) required")
    end
    
    it 'requires a flow id for deleting a configured flow' do
      expect { switch.delete_flow(table_id: 0) }. to raise_error(ArgumentError,
        "Flow ID (flow_id) required")
    end
    
    it 'requires a table id for retrieving a list of operational flows' do
      expect { switch.get_operational_flows }.to raise_error(ArgumentError,
        "Table ID (table_id) required")
    end
    
    it 'requires a table id for retrieving a list of configured flows' do
      expect { switch.get_configured_flows }.to raise_error(ArgumentError,
       "Table ID (table_id) required")
    end
    
    it 'requires a table id to get a list of operational flows in OVS format' do
      expect { switch.get_operational_flows_ovs_syntax }.
        to raise_error(ArgumentError, "Table ID (table_id) required")
    end
    
    it 'requires a table id to get a list of configured flows in OVS format' do
      expect { switch.get_configured_flows_ovs_syntax }.
        to raise_error(ArgumentError, "Table ID (table_id) required")
    end
  end
 end