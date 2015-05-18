require 'spec_helper'
require 'netconfdev/vrouter/vrouter5600'

RSpec.describe VRouter5600 do
  let(:controller) { Controller.new(ip_addr: '1.2.3.4', port_number: '1234',
    admin_name: 'username', admin_password: 'password') }
  let(:vrouter) { VRouter5600.new(controller: controller, name: 'vrouter',
    ip_addr: '4.3.2.1', port_number: '4321', admin_name: 'vrouter_user',
    admin_password: 'vrouter_pass') }

  it 'gets a list of schemas' do
    schemas = {:schemas => {:schema => [{:identifier => 'schema-identifier',
          :version => '2015-04-10', :format => 'ietf-netconf-monitoring:yang',
          :location => ['NETCONF'],
          :namespace => 'urn:opendaylight:schema:namespace'}]}}.to_json
    WebMock.stub_request(:get,
      ("http://#{controller.username}:#{controller.password}@" \
        "#{controller.ip}:#{controller.port}/restconf/operational/" \
        "opendaylight-inventory:nodes/node/#{vrouter.name}/"\
        "yang-ext:mount/ietf-netconf-monitoring:netconf-state/schemas")).
      to_return(:body => schemas)

    response = vrouter.get_schemas
    expect(response.status).to eq(NetconfResponseStatus::OK)
    expect(response.body).to eq(JSON.parse(schemas)["schemas"]["schema"])
  end
  
  it 'gets a particular schema' do
    schema_id = "name-of-schema"
    schema_version = "2015-04-10"
    
    schema = {"get-schema" => {:output => {:data => "some yang data"}}}.to_json
    WebMock.stub_request(:post, 
      "http://#{controller.username}:#{controller.password}@" \
      "#{controller.ip}:#{controller.port}/restconf/operations/" \
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount/" \
      "ietf-netconf-monitoring:get-schema").with(:body =>
      hash_including({:input => {:identifier => schema_id,
          :version => schema_version, :format => "yang"}})).
    to_return(:body => schema)

    response = vrouter.get_schema(id: schema_id, version: schema_version)
    expect(response.status).to eq(NetconfResponseStatus::OK)
    expect(response.body).to eq(JSON.parse(schema)['get-schema']['output']['data'])
  end
  
  it 'retrieves configuration information' do
    config = {'config:property' => {:property => {:key => 'value'}}}.to_json
    WebMock.stub_request(:get,
      "http://#{controller.username}:#{controller.password}@"\
      "#{controller.ip}:#{controller.port}/restconf/config/"\
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount").
    to_return(:body => config)
  
    response = vrouter.get_cfg
    expect(response.status).to eq(NetconfResponseStatus::OK)
    expect(response.body).to eq(JSON.parse(config))
  end
  
  it 'retrieves firewall configurations' do
    config = {:firewalls => {:firewall => [{:key => 'value'}]}}.to_json
    WebMock.stub_request(:get,
      "http://#{controller.username}:#{controller.password}@"\
      "#{controller.ip}:#{controller.port}/restconf/config/"\
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount/"\
      "vyatta-security:security/vyatta-security-firewall:firewall").
    to_return(:body => config)
  
    response = vrouter.get_firewalls_cfg
    expect(response.status).to eq(NetconfResponseStatus::OK)
    expect(response.body).to eq(JSON.parse(config))
  end
  
  it 'creates a firewall instance' do
    rules = Rules.new(name: 'firewall-group')
    rule = Rule.new(rule_number: 1, action: 'accept', source_address: '1.2.3.4')
    rules.add_rule(rule)
    firewall = Firewall.new(rules: rules)
    firewall_json = firewall.to_hash.to_json
    
    WebMock.stub_request(:post,
      "http://#{controller.username}:#{controller.password}@"\
      "#{controller.ip}:#{controller.port}/restconf/config/"\
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount").
    with(:body => firewall_json).to_return(:body => firewall_json,
      :status => 200)
    
    response = vrouter.create_firewall_instance(firewall)
    expect(response.status).to eq(NetconfResponseStatus::OK)
  end
  
  it 'gets configuration information for a particular firewall instance' do
    firewall_name = "dummy_firewall"
    firewall = {'vyatta-security:security' =>
        {'vyatta-security-firewall:firewall' => {:name =>
            [{:rule => [{}], :tagnode => firewall_name}]}}}.to_json
    WebMock.stub_request(:get,
      "http://#{controller.username}:#{controller.password}@"\
      "#{controller.ip}:#{controller.port}/restconf/config/"\
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount/"\
      "vyatta-security:security/vyatta-security-firewall:firewall/name/"\
      "#{firewall_name}").to_return(:body => firewall)
  
    response = vrouter.get_firewall_instance_cfg(firewall_name)
    expect(response.status).to eq(NetconfResponseStatus::OK)
    expect(response.body).to eq(JSON.parse(firewall))
  end
  
  it 'removes a particular firewall instance' do
    rules = Rules.new(name: 'firewall-group')
    rule = Rule.new(rule_number: 1, action: 'accept', source_address: '1.2.3.4')
    rules.add_rule(rule)
    firewall = Firewall.new(rules: rules)
    
    WebMock.stub_request(:delete,
      "http://#{controller.username}:#{controller.password}@"\
      "#{controller.ip}:#{controller.port}/restconf/config/"\
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount/"\
      "vyatta-security:security/vyatta-security-firewall:firewall/name/"\
      "#{rules.name}")
  
    response = vrouter.delete_firewall_instance(firewall)
    expect(response.status).to eq(NetconfResponseStatus::OK)
  end
  
  it 'gets a list of dataplane interfaces available' do
    dataplanes = {:interfaces => {'vyatta-interfaces-dataplane:dataplane' =>
          [{:tagnode => "interface-name"}], 'some-other-interface:interface' =>
          [{:key => 'value'}]}}.to_json
    
    WebMock.stub_request(:get,
      "http://#{controller.username}:#{controller.password}@"\
      "#{controller.ip}:#{controller.port}/restconf/config/"\
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount/"\
      "vyatta-interfaces:interfaces").to_return(:body => dataplanes)
  
    response = vrouter.get_dataplane_interfaces_list
    expect(response.status).to eq(NetconfResponseStatus::OK)
    expect(response.body).to eq(["interface-name"])
  end
  
  it 'gets configuration of all dataplane interfaces' do
    configs = {:interfaces => {'vyatta-interfaces-dataplane:dataplane' =>
          [{:tagnode => "interface-name"}, {:tagnode => 'interface-2'}]}}.to_json
      
    WebMock.stub_request(:get,
      "http://#{controller.username}:#{controller.password}@"\
      "#{controller.ip}:#{controller.port}/restconf/config/"\
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount/"\
      "vyatta-interfaces:interfaces").
    to_return(:body => configs)
  
    response = vrouter.get_dataplane_interfaces_cfg
    expect(response.status).to eq(NetconfResponseStatus::OK)
    expect(response.body).to eq(JSON.parse(configs)['interfaces']['vyatta-interfaces-dataplane:dataplane'])
  end
  
  it 'gets configuration of a particular dataplane interface' do
    interface_name = "intfc1"
    dataplane = {'vyatta-interfaces-dataplane:dataplane' =>
        [{:tagnode => interface_name}]}.to_json
    WebMock.stub_request(:get,
    "http://#{controller.username}:#{controller.password}@"\
    "#{controller.ip}:#{controller.port}/restconf/config/"\
    "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount/"\
    "vyatta-interfaces:interfaces/vyatta-interfaces-dataplane:dataplane/"\
    "#{interface_name}").to_return(:body => dataplane)

    response = vrouter.get_dataplane_interface_cfg(interface_name)
    expect(response.status).to eq(NetconfResponseStatus::OK)
    expect(response.body).to eq(JSON.parse(dataplane))
  end
  
  it 'gets a list of the loopback interfaces' do
    loopbacks = {:interfaces => {'vyatta-interfaces-loopback:loopback' =>
          [{:tagnode => "interface-name"}], 'vyatta-interfaces-dataplane' =>
          [{:tagnode => "dataplace-interface"}]}}.to_json
    
    WebMock.stub_request(:get,
      "http://#{controller.username}:#{controller.password}@"\
      "#{controller.ip}:#{controller.port}/restconf/config/"\
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount/"\
      "vyatta-interfaces:interfaces").to_return(:body => loopbacks)
  
    response = vrouter.get_loopback_interfaces_list
    expect(response.status).to eq(NetconfResponseStatus::OK)
    expect(response.body).to eq(["interface-name"])
  end
  
  it 'gets configuration of all loopback interfaces' do    
    configs = {:interfaces => {'vyatta-interfaces-loopback:loopback' =>
          [{:tagnode => "interface-name"}, {:tagnode => 'interface-2'}]}}.to_json
      
    WebMock.stub_request(:get,
      "http://#{controller.username}:#{controller.password}@"\
      "#{controller.ip}:#{controller.port}/restconf/config/"\
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount/"\
      "vyatta-interfaces:interfaces").
    to_return(:body => configs)
  
    response = vrouter.get_loopback_interfaces_cfg
    expect(response.status).to eq(NetconfResponseStatus::OK)
    expect(response.body).to eq(JSON.parse(configs)['interfaces']['vyatta-interfaces-loopback:loopback'])
  end
  
  it 'gets the configuration for a particular loopback interface' do
    interface_name = "intfc1"
    loopback = {'vyatta-interfaces-loopback:loopback' =>
        [{:tagnode => interface_name}]}.to_json
    WebMock.stub_request(:get,
      "http://#{controller.username}:#{controller.password}@"\
      "#{controller.ip}:#{controller.port}/restconf/config/"\
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount/"\
      "vyatta-interfaces:interfaces/vyatta-interfaces-loopback:loopback/"\
      "#{interface_name}").to_return(:body => loopback)

    response = vrouter.get_loopback_interface_cfg(interface_name)
    expect(response.status).to eq(NetconfResponseStatus::OK)
    expect(response.body).to eq(JSON.parse(loopback))
  end
  
  it 'gets a list of all interfaces' do
    interfaces = {:interfaces => {'vyatta-interfaces-loopback:loopback' =>
          [{:tagnode => "interface-name"}], 'vyatta-interfaces-dataplane' =>
          [{:tagnode => "dataplane-interface"}]}}.to_json
    
     WebMock.stub_request(:get,
      "http://#{controller.username}:#{controller.password}@"\
      "#{controller.ip}:#{controller.port}/restconf/config/"\
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount/"\
      "vyatta-interfaces:interfaces").to_return(:body => interfaces)
  
    response = vrouter.get_interfaces_list
    expect(response.status).to eq(NetconfResponseStatus::OK)
    expect(response.body).to include("interface-name")
    expect(response.body).to include("dataplane-interface")
  end
  
  it 'gets configuration of all interfaces' do
    interfaces = {:interfaces => {'vyatta-interfaces-loopback:loopback' =>
          [{:tagnode => "interface-name"}], 'vyatta-interfaces-dataplane' =>
          [{:tagnode => "dataplane-interface"}]}}.to_json
    
     WebMock.stub_request(:get,
      "http://#{controller.username}:#{controller.password}@"\
      "#{controller.ip}:#{controller.port}/restconf/config/"\
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount/"\
      "vyatta-interfaces:interfaces").to_return(:body => interfaces)
  
    response = vrouter.get_interfaces_cfg
    expect(response.status).to eq(NetconfResponseStatus::OK)
    expect(response.body).to eq(JSON.parse(interfaces))
  end
  
  it 'sets a firewall for a dataplane interface on inbound and outbound traffic' do
    interface_name = "dataplane-interface"
    in_firewall = 'firewall-in'
    out_firewall = 'firewall-out'
    WebMock.stub_request(:put,
      "http://#{controller.username}:#{controller.password}@"\
      "#{controller.ip}:#{controller.port}/restconf/config/"\
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount/"\
      "vyatta-interfaces:interfaces/vyatta-interfaces-dataplane:dataplane/"\
      "#{interface_name}").with(:body =>
      {'vyatta-interfaces-dataplane:dataplane' => {:tagnode => interface_name,
        'vyatta-security-firewall:firewall' => {:in => [in_firewall],
          :out => [out_firewall]}}}.to_json)
  
    response = vrouter.set_dataplane_interface_firewall(interface_name,
      inbound_firewall_name: in_firewall, outbound_firewall_name: out_firewall)
    expect(response.status).to eq(NetconfResponseStatus::OK)
  end
  
  it 'deletes firewall settings from a dataplace interface' do
    interface_name = "dataplane-interface"
    
    WebMock.stub_request(:delete,
      "http://#{controller.username}:#{controller.password}@"\
      "#{controller.ip}:#{controller.port}/restconf/config/"\
      "opendaylight-inventory:nodes/node/#{vrouter.name}/yang-ext:mount/"\
      "vyatta-interfaces:interfaces/vyatta-interfaces-dataplane:dataplane/"\
      "#{interface_name}/vyatta-security-firewall:firewall")
  
    response = vrouter.delete_dataplane_interface_firewall(interface_name)
    expect(response.status).to eq(NetconfResponseStatus::OK)
  end
  
  describe 'argument validation' do
    it 'requires an identifier for a schema lookup' do
      expect { vrouter.get_schema }.to raise_error(ArgumentError,
        "Identifier (id) required")
    end
    
    it 'requires a version for a schema lookup' do
      expect { vrouter.get_schema(id: 'schema-id') }.to raise_error(ArgumentError,
        "Version (version) required")
    end
    
    it 'requires at least one firewall name to be provided when setting the firewall' do
      expect { vrouter.set_dataplane_interface_firewall('interface-name') }.
        to raise_error(ArgumentError, "At least one firewall "\
            "(inbound_firewall_name, outbound_firewall_name) required")
    end
    
    it 'requires a firewall instance to be passed to create a firewall instance' do
      expect { vrouter.create_firewall_instance("firewall") }.
        to raise_error(ArgumentError, "Firewall must be instance of 'Firewall'")
    end
  end
end