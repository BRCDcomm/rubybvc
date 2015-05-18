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

#Class defining response to most requests made in rubybvc.
class NetconfResponse
  require 'utils/netconf_response_status'
  
  # integer: success or failure status of request
  attr_accessor :status
  # <variable>: the response from the request or more information about failure
  attr_accessor :body
  
  def initialize(netconf_response_status = nil, json_body = nil) #:nodoc:
    @status = netconf_response_status
    @body = json_body
  end
  
  ##
  # Return a string for the status.
  #
  # _Return_ _Value_
  # * string :  A string describing the status of the response (success or reason for failure).
  def message
    case(@status)
    when NetconfResponseStatus::OK
      "Success"
    when NetconfResponseStatus::NODE_CONNECTED
      "Node is connected"
    when NetconfResponseStatus::NODE_DISCONNECTED
      "Node is disconnected"
    when NetconfResponseStatus::NODE_NOT_FOUND
      "Node not found"
    when NetconfResponseStatus::NODE_CONFIGURED
      "Node is configured"
    when NetconfResponseStatus::CONN_ERROR
      "Server connection error"
    when NetconfResponseStatus::CTRL_INTERNAL_ERROR
      "Internal server error"
    when NetconfResponseStatus::HTTP_ERROR
      msg = "HTTP error"
      msg += " #{@body.code}" if @body && @body.code
      msg += " - #{@body.message}" if @body && @body.message
      msg
    when NetconfResponseStatus::DATA_NOT_FOUND
      "Requested data not found"
    end
  end
end