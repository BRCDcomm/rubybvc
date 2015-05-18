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

##
# The class that defines firewall Rules.
class Rules

  # String: Name of the firewall rule.
  attr_reader :name

  # List of Rule : List of Rule defining the firewall behavior.
  attr_reader :rules
  
# _Parameters_ 
# * +name+:: String: Name of the firewall rule.
#
  def initialize(name: nil)
    raise ArgumentError, "Name (name) required" unless name
    
    @name = name
    @rules = []
  end
  
  ##
  # Add a rule to this firewall.
  #
  # _Parameters_ 
  # * +rule+:: Rule : A Firewall Rule to add to this Firewall.  
 
  def add_rule(rule)
    raise ArgumentError, "Rule must be instance of 'Rule'" unless rule.is_a?(Rule)
    @rules << rule
  end
  
  def to_hash #:nodoc:
    rules_hash = []
    @rules.each do |rule|
      rules_hash << rule.to_hash
    end
    {:rule => rules_hash, :tagnode => @name}
  end
end