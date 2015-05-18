# Copyright (c) 2015,  BROCADE COMMUNICATIONS SYSTEMS, INC
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
# THE POSSIBILITY OF SUCH DAMAGE.

# Class that represents OpenFlow flow matching attributes 
class Match
  require 'utils/hash_with_compact'

  # integer : Ethernet type
  attr_reader :eth_type
  # string : IPv4 Destination IP address
  attr_reader :ipv4_dst
  # string : IPv4 Source IP address
  attr_reader :ipv4_src
  # string : IPv6 Source IP address
  attr_reader :ipv6_src
  # string : IPv6 Destination IP address
  attr_reader :ipv6_dst
  # string : IPv6 Flow Label
  attr_reader :ipv6_flabel
  # integer : IPv6 Extension header
  attr_reader :ipv6_ext_hdr
  # string : Ethernet Destination address e.g. "00:11:22:33:44:55"
  attr_reader :ethernet_dst
  # string : Ethernet Source address e.g. "00:11:22:33:44:55" 
  attr_reader :ethernet_src
  # integer : Input physical port - not used for matches
  attr_reader :in_phy_port
  # integer : Input port
  attr_reader :in_port
  # integer : Ip protocol
  attr_reader :ip_proto
  # integer : Differentiated Services Code Point
  attr_reader :ip_dscp
  # integer : Explicit Congestion Notificaiton
  attr_reader :ip_ecn
  # integer : TCP Source port number
  attr_reader :tcp_src_port
  # integer : TCP Destination port number
  attr_reader :tcp_dst_port
  # integer : UDP Source port number
  attr_reader :udp_src_port
  # integer : UDP Destination port number
  attr_reader :udp_dst_port
  # integer : ICMPv4 type
  attr_reader :icmpv4_type
  # integer : ICMPv4 code
  attr_reader :icmpv4_code
  # integer : ICMPv6 type
  attr_reader :icmpv6_type
  # integer : ICMPv6 code
  attr_reader :icmpv6_code
  # integer : ARP opcode
  attr_reader :arp_op_code
  # string : ARP source IPv4 address.  e.g. "111.222.333.444"
  attr_reader :arp_src_ipv4
  # string : ARP target IPv4 address.  e.g. "111.222.333.444"
  attr_reader :arp_tgt_ipv4
  # string : ARP source hardware address.  e.g. "111.222.333.444"   
  attr_reader :arp_src_hw_addr
  # string : ARP target hardware address.  e.g. "111.222.333.444"
  attr_reader :arp_tgt_hw_addr
  # integer: VLAN identifier
  attr_reader :vlan_id
  # integer: VLAN priority code point
  attr_reader :vlan_pcp
  # integer : Stream control transmission protocol destination port
  attr_reader :sctp_dst
  # integer : Stream control transmission protocol source port
  attr_reader :sctp_src
  # integer : Multiprotocol Label Switching label
  attr_reader :mpls_label
  # integer : Multiprotocol Label Switching traffic class
  attr_reader :mpls_tc
  # integer : Multiprotocol Label Switching bottom of stack flag
  attr_reader :mpls_bos
  # integer : tunnel identifier
  attr_reader :tunnel_id
  # integer : Openflow intra-table metadata
  attr_reader :metadata
  # integer : Openflow intra-table metadata mask
  attr_reader :metadata_mask


    
  # _Parameters_ 
  # * +eth_type+:: integer : Ethernet type
  # * +ipv4_destination+:: string : IPv4 Destination IP address
  # * +ipv4_source+:: string : IPv4 Source IP address
  # * +ipv6_source+:: string : IPv6 Source IP address
  # * +ipv6_destination+:: string : IPv6 Destination IP address
  # * +ipv6_flabel+:: string : IPv6 Flow Label
  # * +ipv6_ext_header+:: integer : IPv6 Extension header
  # * +ethernet_destination+:: string : Ethernet Destination address e.g. "00:11:22:33:44:55"
  # * +ethernet_source+:: string : Ethernet Source address e.g. "00:11:22:33:44:55" 
  # * +in_physical_port+:: integer : Input physical port - not used for matches
  # * +in_port+:: integer : Input port
  # * +ip_protocol_num+:: integer : Ip protocol
  # * +ip_dscp+:: integer : Differentiated Services Code Point
  # * +ip_ecn+:: integer : Explicit Congestion Notificaiton
  # * +tcp_source_port+:: integer : TCP Source port number
  # * +tcp_destination_port+:: integer : TCP Destination port number
  # * +udp_source_port+:: integer : UDP Source port number
  # * +udp_destination_port+:: integer : UDP Destination port number
  # * +icmpv4_type+:: integer : ICMPv4 type
  # * +icmpv4_code+:: integer : ICMPv4 code
  # * +icmpv6_type+:: integer : ICMPv6 type
  # * +icmpv6_code+:: integer : ICMPv6 code
  # * +arp_op_code+:: integer : ARP opcode
  # * +arp_source_ipv4+:: string : ARP source IPv4 address.  e.g. "111.222.333.444"
  # * +arp_target_ipv4+:: string : ARP target IPv4 address.  e.g. "111.222.333.444"
  # * +arp_source_hardware_address+:: string : ARP source hardware address.  e.g. "111.222.333.444"
  # * +arp_target_hardware_address+:: string : ARP target hardware address.  e.g. "111.222.333.444"
  # * +vlan_id+:: integer: VLAN identifier
  # * +vlan_pcp+:: integer: VLAN priority code point
  # * +sctp_destination+:: integer : Stream control transmission protocol destination port
  # * +sctp_source+:: integer : Stream control transmission protocol source port
  # * +mpls_label+:: integer : Multiprotocol Label Switching label
  # * +mpls_tc+:: integer : Multiprotocol Label Switching traffic class
  # * +mpls_bos+:: integer : Multiprotocol Label Switching bottom of stack flag
  # * +tunnel_id+:: integer : tunnel identifier
  # * +metadata+:: integer : Openflow intra-table metadata
  # * +metadata_mask+:: integer : Openflow intra-table metadata mask

  def initialize(eth_type: nil, ipv4_destination: nil, ipv4_source: nil,
      ipv6_source: nil, ipv6_destination: nil, ipv6_flabel: nil,
      ipv6_ext_header: nil, ethernet_destination: nil, ethernet_source: nil,
      in_port: nil, in_physical_port: nil, ip_protocol_num: nil, ip_dscp: nil,
      ip_ecn: nil, tcp_source_port: nil, tcp_destination_port: nil,
      udp_source_port: nil, udp_destination_port: nil, icmpv4_type: nil,
      icmpv4_code: nil, icmpv6_type: nil, icmpv6_code: nil,
      arp_op_code: nil, arp_source_ipv4: nil, arp_target_ipv4: nil,
      arp_source_hardware_address: nil, arp_target_hardware_address: nil,
      vlan_id: nil, vlan_pcp: nil, sctp_destination: nil, sctp_source: nil,
      mpls_label: nil, mpls_tc: nil, mpls_bos: nil, tunnel_id: nil,
      metadata: nil, metadata_mask: nil)
    @eth_type = eth_type
    @ipv4_dst = ipv4_destination
    @ipv4_src = ipv4_source
    @ipv6_dst = ipv6_destination
    @ipv6_src = ipv6_source
    @ipv6_flabel = ipv6_flabel
    @ipv6_ext_hdr = ipv6_ext_header
    @ethernet_dst = ethernet_destination
    @ethernet_src = ethernet_source
    @in_port = in_port
    @in_phy_port = in_physical_port
    @ip_proto = ip_protocol_num
    @ip_dscp = ip_dscp
    @ip_ecn = ip_ecn
    @tcp_src_port = tcp_source_port
    @tcp_dst_port = tcp_destination_port
    @udp_dst_port = udp_destination_port
    @udp_src_port = udp_source_port
    @icmpv4_type = icmpv4_type
    @icmpv4_code = icmpv4_code
    @icmpv6_type = icmpv6_type
    @icmpv6_code = icmpv6_code
    @arp_op_code = arp_op_code
    @arp_src_ipv4 = arp_source_ipv4
    @arp_tgt_ipv4 = arp_target_ipv4
    @arp_src_hw_addr = arp_source_hardware_address
    @arp_tgt_hw_addr = arp_target_hardware_address
    @vlan_id = vlan_id
    @vlan_pcp = vlan_pcp
    @sctp_dst = sctp_destination
    @sctp_src = sctp_source
    @mpls_label = mpls_label
    @mpls_tc = mpls_tc
    @mpls_bos = mpls_bos
    @tunnel_id = tunnel_id
    @metdata = metadata
    @metadata_mask = metadata_mask
  end
  
  def to_hash #:nodoc:
    hash = {'ethernet-match' => {'ethernet-type' => {:type => @eth_type},
      'ethernet-destination' => {:address => @ethernet_dst},
      'ethernet-source' => {:address => @ethernet_src}},
      'ipv4-destination' => @ipv4_dst, 'ipv4-source' => @ipv4_src,
      'ipv6-destination' => @ipv6_dst, 'ipv6-source' => @ipv6_src,
      'ipv6-label' => {'ipv6-flabel' => @ipv6_flabel},
      'ipv6-ext-header' => {'ipv6-exthdr' => @ipv6_ext_hdr},
      'in-port' => @in_port, 'in_phy_port' => @in_phy_port,
      'ip-match' => {'ip-dscp' => @ip_dscp, 'ip-ecn' => @ip_ecn,
        'ip-protocol' => @ip_proto}, 'tcp-destination-port' => @tcp_dst_port,
      'tcp-source-port' => @tcp_src_port, 'udp-source-port' => @udp_src_port,
      'udp-destination-port' => @udp_dst_port, 'icmpv4-match' =>
        {'icmpv4-code' => @icmpv4_code, 'icmpv4-type' => @icmpv4_type},
      'icmpv6-match' => {'icmpv6-code' => @icmpv6_code, 'icmpv6-type' => @icmpv6_type},
      'arp-op' => @arp_op_code, 'arp-source-transport-address' => @arp_src_ipv4,
      'arp-source-hardware-address' => {:address => @arp_src_hw_addr},
      'arp-target-hardware-address' => {:address => @arp_tgt_hw_addr},
      'arp-target-transport-address' => @arp_tgt_ipv4,
      'vlan-match' => {'vlan-id' => {'vlan-id' => @vlan_id,
          'vlan-id-present' => !@vlan_id.nil?}, 'vlan-pcp' => @vlan_pcp},
      'sctp-source-port' => @sctp_src, 'sctp-destination-port' => @sctp_dst,
      'protocol-match-fields' => {'mpls-label' => @mpls_label,
        'mpls-tc' => @mpls_tc, 'mpls-bos' => @mpls_bos},
      :tunnel => {'tunnel-id' => @tunnel_id},
      :metadata => {:metadata => @metadata, 'metadata-mask' => @metadata_mask}}
    hash.delete("vlan-match") if !@vlan_id
    hash
  end
end