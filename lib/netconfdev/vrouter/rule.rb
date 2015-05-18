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

# The class that defines a Firewall Rule.
class Rule

  # Integer: The rule number.  e.g. 40
  attr_reader :number
  # String: The action for the rule.  e.g. "drop" or "accept"
  attr_reader :action
  # String: The source IP address on which the rule will match.  e.g. "172.22.17.107"
  attr_reader :src_address

# _Parameters_ 
# * +rule_number+:: Integer: The rule number.  e.g. 40 
# * +action+:: String: The action for the rule.  e.g. "drop" or "accept"
# * +source_address+:: String: The source IP address on which the rule will match.  e.g. "172.22.17.107"
# * +icmp_typename+:: String : [optional] ICMP type.  e.g. "ping"

  def initialize(rule_number: nil, action: nil, source_address: nil,
    icmp_typename: nil)
    raise ArgumentError, "Rule number (rule_number) required" unless rule_number
    raise ArgumentError, "Action (action) required" unless action
    # either of the other two required? at least one required?
    
    @number = rule_number
    @action = action
    @src_address = source_address
    @icmp_typename = icmp_typename
    @protocol = "icmp" if icmp_typename
  end
  
  def to_hash #:nodoc:
    hash = {:action => @action, :source => {:address => @src_address},
      :tagnode => @number, :protocol => @protocol, :icmp =>
        {'type-name' => @icmp_typename}}
    hash.compact
  end
end