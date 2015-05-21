# rubybvc
Ruby gem to program your network via the Brocade Vyatta Controller

## Other Brocade Vyatta Controller libraries 
* pybvc - Python library for programming BVC:  https://github.com/BRCDcomm/pybvc 

## Current Version:
1.0.0

## Prerequisites
   - Ruby 2.1.x: 
       - Test if your system already has it

         ```bash
         ruby --version
         ```
          - If it is installed you should see a response similar to this (version and OS may change it a bit):

          ```
          ruby 2.1.0p0 (2013-12-25 revision 44422) [x86_64-darwin12.0]
          ```
          - If it is not installed, then download and install: https://www.ruby-lang.org/en/documentation/installation/ 

## Installation:
```bash
gem install rubybvc
```

## Upgrade:
```bash
gem update rubybvc
```

## Check installed version:
```bash
gem list rubybvc
```


## Documentation:
   - [Video introduction](https://www.youtube.com/watch?v=dZxZAtg3R0A)
   - [Programmer's Reference](http://brcdcomm.github.io/rubybvc/)

## Sample Applications:
   - [rubybvcsamples](https://github.com/brcdcomm/rubybvcsamples)
   - To install samples:

     ```bash
     git clone https://github.com/brcdcomm/rubybvcsamples.git
     ```

## Example 1:  Add and remove firewall on Vyatta vrouter5600 via BVC:

```ruby
require 'rubybvc'
require 'yaml'

controller = Controller.new(ip_addr: '172.22.18.153',
  admin_name: 'admin',
  admin_password: 'admin')

vrouter = VRouter5600.new(controller: controller, name: 'vRouter',
  ip_addr: config['node']['ip_addr'], port_number: 830,
  admin_name: 'vyatta',
  admin_password: 'vyatta')

puts "\nAdd #{vrouter.name} to controller"
response = controller.add_netconf_node(vrouter)

puts "\nShow firewalls configuration of #{vrouter.name}"
response = vrouter.get_firewalls_cfg

firewall_group = "FW-ACCEPT-SRC-172_22_17_108"
rules = Rules.new(name: firewall_group)
rule = Rule.new(rule_number: 33, action: "accept",
  source_address: '172.22.17.108')
rules.add_rule(rule)
firewall = Firewall.new(rules: rules)
puts "\nCreate new firewall instance #{firewall_group} on #{vrouter.name}"
response = vrouter.create_firewall_instance(firewall)


puts "\nShow content of the firewall instance #{firewall_group} on #{vrouter.name}"
response = vrouter.get_firewall_instance_cfg(firewall_group)

puts "\nShow firewalls configuration on #{vrouter.name}"
response = vrouter.get_firewalls_cfg

puts "\nRemove firewall instance #{firewall_group} from #{vrouter.name}"
response = vrouter.delete_firewall_instance(firewall)

puts "\nShow firewalls configuration on #{vrouter.name}"
response = vrouter.get_firewalls_cfg

puts "\nRemove #{vrouter.name} NETCONF node from controller"
response = controller.delete_netconf_node(vrouter)

```



### Example 2:  Add a flow that drops packets that match in-port, ethernet src/dest addr, ip src/dest/dscp/ecn/protocol and tcp src/dest ports

```ruby

require 'rubybvc'
require 'yaml'

puts "\nStarting Demo 10: Setting OpenFlow flow on the Controller: "\
  "foward normal traffic with particular ethernet source and destination "\
  "addresses, specific IPv4 source and destination addresses specific UDP "\
  "source and destination port numbers, coming in on a particular port "\
  "following a particular IP protocol, DSCP and ECN"

puts "\nCreating controller instance"
controller = Controller.new(ip_addr: "172.22.18.153",
  admin_name: 'admin',
  admin_password: 'admin')

name = "openflow:1"
of_switch = OFSwitch.new(controller: controller, name: name)
# Ethernet type MUST be 2048 (0x800) -> IPv4 protocol
eth_type = 2048
eth_src = "00:00:00:11:23:ae"
eth_dst = "20:14:29:01:19:61"
ipv4_src = "192.1.2.3/10"
ipv4_dst = "172.168.5.6/18"
ip_proto = 17
ip_dscp = 8
ip_ecn = 3
udp_src_port = 25364
udp_dst_port = 8080
input_port = 13

flow_id = 18
table_id = 0
flow_entry = FlowEntry.new(flow_priority: 1008, flow_id: flow_id,
  flow_table_id: table_id)

# Instruction: 'Apply-action'
#      Action: 'Drop'
instruction = Instruction.new(instruction_order: 0)
action = OutputAction.new(order: 0, port: "DROP")
instruction.add_apply_action(action)
flow_entry.add_instruction(instruction)

# Match fields: Ethernet type
#               Ethernet Source Address
#               Ethernet Destination Address
#               IPv4 Source Address
#               IPv4 Destination Address
#               IP Protocol Number
#               IP DSCP
#               IP ECN
#               UDP Source Port Number
#               UDP Destination Port Number
#               Input port
match = Match.new(eth_type: eth_type, ethernet_source: eth_src,
  ethernet_destination: eth_dst, ipv4_destination: ipv4_dst,
  ipv4_source: ipv4_src, ip_protocol_num: ip_proto, ip_dscp: ip_dscp,
  ip_ecn: ip_ecn, udp_source_port: udp_src_port,
  udp_destination_port: udp_dst_port, in_port: input_port)
flow_entry.add_match(match)

response = of_switch.get_configured_flow(table_id: table_id, flow_id: flow_id)

puts "\nDelete flow with ID #{flow_id} from Controller's cache and from table "\
  "#{table_id} on #{name} node"
response = of_switch.delete_flow(flow_id: flow_id, table_id: table_id)

```
