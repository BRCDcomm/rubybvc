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

#Class to define an OpenFlow action to add a VLAN encapsulation.
class PushVlanHeaderAction < Action

# _Parameters_ 
# * +order+:: integer : The order of the action relative to other actions in Instruction.
# * +eth_type+:: integer : The ethernet type of the packet.
# * +tag+:: integer : Tag protocol identifier.
# * +pcp+:: integer : Priority code point.
# * +cfi+:: integer : Drop eligible indicator (formerly cannonical format indicator).
# * +vlan_id+:: integer : VLAN identifier.

  def initialize(order: 0, eth_type: nil, tag: nil, pcp: nil, cfi: nil,
      vlan_id: nil)
    super(order: order)
    @eth_type = eth_type
    @tag = tag
    @pcp = pcp
    @cfi = cfi
    @vlan_id = vlan_id
  end
  
  def to_hash #:nodoc:
    {:order => @order, 'push-vlan-action' => {'ethernet-type' => @eth_type,
      :tag => @tag, :pcp => @pcp, :cfi => @cfi, 'vlan-id' => @vlan_id}}
  end
end