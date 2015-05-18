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

require 'controller/node'

##
# Class that represents a NetconfNode
#
class NetconfNode < Node


  # String : IP address for NETCONF protocol of NETCONF device.  e.g. 172.22.11.44 
  attr_reader :ip
  # String : Port number of the NETCONF protocol.   e.g. 830
  attr_reader :port
  # String : Admin userid for logon to NETCONF device.  e.g. vyatta
  attr_reader :username
  # String : Admin password for logon NETCONF device.  e.g. vyatta
  attr_reader :password
  # Boolean : True if only TCP is used to communicate with NETCONF device.
  attr_reader :tcp_only

  # _Parameters_ 
# * +controller+:: Controller : The controller object through which NETCONF device is to be accessed.
# * +name+:: String : The name of the NETCONF node.  e.g. vrouter
# * +ip_addr+:: String : IP address for NETCONF protocol of NETCONF device.  e.g. 172.22.11.44 
# * +port_number+:: String : Port number of the NETCONF protocol.   e.g. 830
# * +admin_name+:: String : Admin userid for logon to NETCONF device.  e.g. vyatta
# * +admin_password+:: String : Admin password for logon NETCONF device.  e.g. vyatta
# * +tcp_only+:: Boolean : True if only TCP is used to communicate with NETCONF device.
#
  def initialize(controller: nil, name: nil, ip_addr: nil,
      port_number: nil, admin_name: nil, admin_password: nil,
      tcp_only: false)
    super(controller: controller, name: name)
    raise ArgumentError, "IP Address (ip_addr) required" unless ip_addr
    raise ArgumentError, "Port Number (port_number) required" unless port_number
    raise ArgumentError, "Admin Username (admin_name) required" unless admin_name
    raise ArgumentError, "Admin Password (admin_password) required" unless admin_password
    
    @ip = ip_addr
    @port = port_number
    @username = admin_name
    @password = admin_password
    @tcp_only = tcp_only
  end
  
  def to_hash #:nodoc:
    {:controller => @controller.to_hash, :name => @name, :ip_addr => @ip,
      :port_num => @port, :admin_name => @username, :admin_password => @password}
  end
end