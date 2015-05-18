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

# Class for creating and interacting with OpenFlow flows
class FlowEntry
  require 'openflowdev/instruction'
  require 'openflowdev/match'
  
  # string: ID of the table to put the flow in
  attr_reader :table_id
  # integer: Unique identifier of this FlowEntry in the Controller's data store
  attr_reader :id
  # integer: Priority level of flow entry
  attr_reader :priority
  # integer: Idle time before discarding (seconds)
  attr_reader :idle_timeout
  # integer: Max time before discarding (seconds)
  attr_reader :hard_timeout
  # boolean: Modify/Delete entry strictly matching wildcards and priority
  attr_reader :strict
  # internal Controller's inventory attribute
  attr_reader :install_hw
  # boolean: Boolean flag used to enforce OpenFlow switch to do ordered message processing.
  # Barrier request/reply messages are used by the controller to ensure message dependencies
  # have been met or to receive notifications for completed operations. When the controller
  # wants to ensure message dependencies have been met or wants to receive notifications for
  # completed operations, it may use an OFPT_BARRIER_REQUEST message. This message has no body.
  # Upon receipt, the switch must finish processing all previously-received messages, including
  # sending corresponding reply or error messages, before executing any messages beyond the
  # Barrier Request.
  attr_reader :barrier
  # integer: Opaque Controller-issued identifier
  attr_reader :cookie
  # integer: Mask used to restrict the cookie bits that must match when the command is
  # OFPFC_MODIFY* or OFPFC_DELETE*. A value of 0 indicates no restriction
  attr_reader :cookie_mask
  # string: FlowEntry name in the FlowTable (internal Controller's inventory attribute)
  attr_reader :name
  # list of Instruction: Instructions to be executed when a flow matches this entry flow match fields
  attr_reader :instructions
  # Match: Flow match fields
  attr_reader :match
  # integer: For delete commands, require matching entries to include this as an
  # output port. A value of OFPP_ANY indicates no restriction.
  attr_reader :out_port
  # integer: For delete commands, require matching entries to include this as an
  # output group. A value of OFPG_ANY indicates no restriction
  attr_reader :out_group
  # integer: Bitmap of OpenFlow flags (OFPFF_* from OpenFlow spec)
  attr_reader :flags
  # Buffered packet to apply to, or OFP_NO_BUFFER. Not meaningful for delete
  attr_reader :buffer_id

  # _Parameters_ 
  # * +flow_table_id+:: string: ID of the table to put the flow in
  # * +flow_id+:: integer: Unique identifier of this FlowEntry in the Controller's data store
  # * +flow_priority+:: integer: Priority level of flow entry
  # * +name+:: string: FlowEntry name in the FlowTable (internal Controller's inventory attribute)
  # * +idle_timeout+:: integer: Idle time before discarding (seconds)
  # * +hard_timeout+:: integer: Max time before discarding (seconds)
  # * +strict+:: boolean: Modify/Delete entry strictly matching wildcards and priority
  # * +install_hw+:: internal Controller's inventory attribute
  # * +barrier+:: boolean: Boolean flag used to enforce OpenFlow switch to do ordered message processing.
  # Barrier request/reply messages are used by the controller to ensure message dependencies
  # have been met or to receive notifications for completed operations. When the controller
  # wants to ensure message dependencies have been met or wants to receive notifications for
  # completed operations, it may use an OFPT_BARRIER_REQUEST message. This message has no body.
  # Upon receipt, the switch must finish processing all previously-received messages, including
  # sending corresponding reply or error messages, before executing any messages beyond the
  # Barrier Request.
  # * +cookie+:: integer: Opaque Controller-issued identifier
  # * +cookie_mask+:: integer: Mask used to restrict the cookie bits that must match when the command is
  # OFPFC_MODIFY* or OFPFC_DELETE*. A value of 0 indicates no restriction
  # * +out_port+:: integer: For delete commands, require matching entries to include this as an
  # output port. A value of OFPP_ANY indicates no restriction.
  # * +out_group+:: integer: For delete commands, require matching entries to include this as an
  # output group. A value of OFPG_ANY indicates no restriction
  # * +flags+:: integer: Bitmap of OpenFlow flags (OFPFF_* from OpenFlow spec)
  # * +buffer_id+:: Buffered packet to apply to, or OFP_NO_BUFFER. Not meaningful for delete


  def initialize(flow_table_id: 0, flow_id: nil, flow_priority: nil, name: nil,
      idle_timeout: 0, hard_timeout: 0, strict: false, install_hw: false,
      barrier: false, cookie: nil, cookie_mask: nil, out_port: nil,
      out_group: nil, flags: nil, buffer_id: nil)
    raise ArgumentError, "Flow ID (flow_id) required" unless flow_id
    raise ArgumentError, "Flow Priority (flow_priority) required" unless flow_priority
    
    @table_id = flow_table_id
    @id = flow_id
    @name = name
    @priority = flow_priority
    @idle_timeout = idle_timeout
    @hard_timeout = hard_timeout
    @strict = strict
    @install_hw = install_hw
    @barrier = barrier
    @cookie = cookie
    @cookie_mask = cookie_mask
    @instructions = []
    @out_port = out_port
    @out_group = out_group
    @flags = flags
    @buffer_id = buffer_id
  end
  
  ##
  # Add an Instruction to the flow entry.
  #
  # _Parameters_ 
  # * +instruction+:: Instruction : Instruction to add to the flow entry. 
  def add_instruction(instruction)
    raise ArgumentError, "Instruction must be of type 'Instruction'" unless instruction.is_a?(Instruction)
    @instructions << instruction
  end

  ##
  # Add a match rule to the flow entry.
  #
  # _Parameters_ 
  # * +match+:: Match : Match to add to the flow entry. 
  def add_match(match)
    raise ArgumentError, "Match must be of type 'Match'" unless match.is_a?(Match)
    @match = match
  end
  
  def to_hash #:nodoc:
    instructions_hash = []
    @instructions.each do |instruction|
      instructions_hash << instruction.to_hash
    end
    
    hash = {'flow-node-inventory:flow' => {:barrier => @barrier,
      'hard-timeout' => @hard_timeout, :id => @id,
      'idle-timeout' => @idle_timeout, 'installHw' => @install_hw,
      'out-port' => @out_port, 'out-group' => @out_group, :flags => @flags,
      'buffer-id' => @buffer_id, :match => @match.to_hash, :priority => @priority,
      :strict => @strict, :table_id => @table_id, :cookie => @cookie,
      :cookie_mask => @cookie_mask, 'flow-name' => @name,
      :instructions => {:instruction => instructions_hash}}}
    hash = hash.compact
    hash
  end
end