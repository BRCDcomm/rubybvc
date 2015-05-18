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

# Class representing OpenFlow flow instruction
class Instruction
  # integer : order that action is to be carried out relative to other instructions.
  attr_accessor :order
  # Action : list of Action
  attr_reader :actions
  
  ##
  # _Parameters_
  # * +instruction_order+:: Order in which to carry out this instruction relative to other instructions.
  def initialize(instruction_order: nil)
    raise ArgumentError, "Instruction Order (instruction_order) required" unless instruction_order
    @order = instruction_order
    @actions = []
  end
  
  ##
  # Add action to an Instruction.
  #
  # _Parameters_ 
  # * +action+:: Action : What action to take 
  def add_apply_action(action)
    raise ArgumentError, "Action must be a subclass of 'Action'" unless action.is_a?(Action)
    @actions << action
  end
  
  def to_hash #:nodoc:
    actions_hash = []
    @actions.each do |action|
      actions_hash << action.to_hash
    end
    {:order => @order, 'apply-actions' => {:action => actions_hash}}
  end
end