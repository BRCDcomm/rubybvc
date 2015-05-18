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
# Class that represents a VRouter 5600 device.
#
class VRouter5600 < NetconfNode
  require 'netconfdev/vrouter/firewall'
  require 'netconfdev/vrouter/rules'
  require 'netconfdev/vrouter/rule'
  require 'netconfdev/vrouter/dataplane_firewall'
  
  ##
  # Return a list of YANG schemas for this VRouter5600.
  #
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and list of YANG schemas for the node.
  def get_schemas
    @controller.get_schemas(@name)
  end
 
  ##
  # Return a YANG schema for the indicated schema on the VRouter5600.
  #
  # _Parameters_ 
  # * +id+:: String : Identifier for schema
  # * +version+:: String : Version/date for schema
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and YANG schema.  
  def get_schema(id: nil, version: nil)
    raise ArgumentError, "Identifier (id) required" unless id
    raise ArgumentError, "Version (version) required" unless version
    
    @controller.get_schema(@name, id: id, version: version)
  end

  ##
  # Return configuration of the VRouter5600.
  #
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and configuration of VRouter5600. 
  def get_cfg
    get_uri = @controller.get_ext_mount_config_uri(self)
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      NetconfResponse.new(NetconfResponseStatus::OK, body)
    end
  end

  ##
  # Return firewall configuration of the VRouter5600.
  #
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and Firewall configuration JSON.  
  def get_firewalls_cfg
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-security:security/vyatta-security-firewall:firewall"
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      NetconfResponse.new(NetconfResponseStatus::OK, body)
    end
  end

  ##
  # Return configuration for a specific firewall on the VRouter5600.
  #
  # _Parameters_ 
  # * +firewall_or_name+:: Firewall or String : A Firewall object or name of firewall for which you want the configuration.  
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and configuration of requested firewall.  
  def get_firewall_instance_cfg(firewall_or_name)
    firewall_name = firewall_or_name.is_a?(Firewall) ? firewall_or_name.rules.name :
      firewall_or_name 
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-security:security/vyatta-security-firewall:firewall/name/"\
      "#{firewall_name}"
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      NetconfResponse.new(NetconfResponseStatus::OK, body)
    end
  end

  ##
  # Create a firewall on the VRouter5600.
  #
  # _Parameters_ 
  # * +firewall+:: Firewall : firewall object describing the firewall to be created. 
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ).  
  def create_firewall_instance(firewall)
    raise ArgumentError, "Firewall must be instance of 'Firewall'" unless firewall.is_a?(Firewall)
    post_uri = @controller.get_ext_mount_config_uri(self)
    response = @controller.rest_agent.post_request(post_uri, firewall.to_hash,
      headers: {'Content-Type' => 'application/yang.data+json'})
    check_response_for_success(response) do
      NetconfResponse.new(NetconfResponseStatus::OK)
    end
  end

  ##
  # Delete a firewall from the VRouter5600.
  #
  # _Parameters_ 
  # * +firewall_or_name+:: Firewall or String : A Firewall object or name of firewall for which you want to remove from vRouter5600.  
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and error info if an error.  
  def delete_firewall_instance(firewall_or_name)
    firewall_name = firewall_or_name.is_a?(Firewall) ? firewall_or_name.rules.name :
      firewall_or_name
    delete_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-security:security/vyatta-security-firewall:firewall/name/"\
      "#{firewall_name}"
    response = @controller.rest_agent.delete_request(delete_uri)
    if response.code.to_i == 200
      NetconfResponse.new(NetconfResponseStatus::OK)
    else
      handle_error_response(response)
    end
  end

  ##
  # Return a list of interfaces on the VRouter5600
  #
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and a list of datapath interfaces.  
  def get_dataplane_interfaces_list
    response = get_interfaces_config
    check_response_for_success(response) do |body|
      if body.has_key?('interfaces') && body['interfaces'].is_a?(Hash) &&
          body['interfaces'].has_key?('vyatta-interfaces-dataplane:dataplane')
        dp_interface_list = []
        body['interfaces']['vyatta-interfaces-dataplane:dataplane'].each do |interface|
          dp_interface_list << interface['tagnode']
        end
        NetconfResponse.new(NetconfResponseStatus::OK, dp_interface_list)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end

  ##
  # Return the configuration for the dataplane interfaces on the VRouter5600.
  #
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and the configuration of the dataplane interfaces.  
  def get_dataplane_interfaces_cfg
    response = get_interfaces_config
    check_response_for_success(response) do |body|
      if body.has_key?('interfaces') && body['interfaces'].is_a?(Hash) &&
          body['interfaces'].has_key?('vyatta-interfaces-dataplane:dataplane')
        NetconfResponse.new(NetconfResponseStatus::OK,
          body['interfaces']['vyatta-interfaces-dataplane:dataplane'])
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end

  ##
  # Return the configuration for a dataplane interface on the VRouter5600
  #
  # _Parameters_ 
  # * +interface_name+:: String : name of the dataplane interface from #get_dataplane_interfaces_list 
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and configuration of the requested dataplane interface.  
  def get_dataplane_interface_cfg(interface_name)
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-interfaces:interfaces/vyatta-interfaces-dataplane:dataplane/"\
      "#{interface_name}"
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      NetconfResponse.new(NetconfResponseStatus::OK, body)
    end
  end

  ##
  # Return a list of loopback interfaces on the VRouter5600
  #
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and list of loopback interfaces.  
  def get_loopback_interfaces_list
    response = get_interfaces_config
    check_response_for_success(response) do |body|
      if body.has_key?('interfaces') && body['interfaces'].is_a?(Hash) &&
          body['interfaces'].has_key?('vyatta-interfaces-loopback:loopback')
        lb_interface_list = []
        body['interfaces']['vyatta-interfaces-loopback:loopback'].each do |interface|
          lb_interface_list << interface['tagnode']
        end
        NetconfResponse.new(NetconfResponseStatus::OK, lb_interface_list)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end

  ##
  # Return the configuration for the loopback interfaces on the VRouter 5600.
  #
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and list of configurations of loopback interfaces.  
  def get_loopback_interfaces_cfg
    response = get_interfaces_config
    check_response_for_success(response) do |body|
      if body.has_key?('interfaces') && body['interfaces'].is_a?(Hash) &&
          body['interfaces'].has_key?('vyatta-interfaces-loopback:loopback')
        NetconfResponse.new(NetconfResponseStatus::OK,
          body['interfaces']['vyatta-interfaces-loopback:loopback'])
      end
    end
  end

  ##
  # Return the configuration for a single loopback interface on the VRouter 5600.
  #
  # _Parameters_ 
  # * +interface_name+:: String : name of the loopback interface from the #get_loopback_interfaces_list 
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and configuration for the requested loopback interface.  
  def get_loopback_interface_cfg(interface_name)
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-interfaces:interfaces/vyatta-interfaces-loopback:loopback/"\
      "#{interface_name}"
    response = @controller.rest_agent.get_request(get_uri)
    check_response_for_success(response) do |body|
      NetconfResponse.new(NetconfResponseStatus::OK, body)
    end
  end

  ##
  # Set a firewall for inbound, outbound or both for a dataplane interface on the VRouter 5600.
  #
  # _Parameters_ 
  # * +interface_name+:: String : The dataplane interface to attach firewalls. 
  # * +inbound_firewall_name+:: String : [optional] name of firewall on VRouter5600 to use for traffic inbound towards router.
  # * +outbound_firewall_name+:: String : [optional] name of firewall on VRouter5600 to use for traffic outbound from router.
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and YANG schema.  
  def set_dataplane_interface_firewall(interface_name,
      inbound_firewall_name: nil, outbound_firewall_name: nil)
    raise ArgumentError, "At least one firewall (inbound_firewall_name, "\
      "outbound_firewall_name) required" unless inbound_firewall_name || outbound_firewall_name
    dpif = DataplaneFirewall.new(interface_name: interface_name,
      in_firewall_name: inbound_firewall_name,
      out_firewall_name: outbound_firewall_name)
    
    put_uri = "#{@controller.get_ext_mount_config_uri(self)}/#{dpif.get_uri}"
    response = @controller.rest_agent.put_request(put_uri, dpif.to_hash,
      headers: {'Content-Type' => 'application/yang.data+json'})
    if response.code.to_i == 200
      NetconfResponse.new(NetconfResponseStatus::OK)
    else
      handle_error_response(response)
    end
  end

  ##
  # Delete both inbound and outbound firewalls for a dataplane interface on the VRouter 5600.
  #
  # _Parameters_ 
  # * +interface_name+:: String : name of the dataplane interface to detach firewalls from. 
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and error details (if status is error).  
  def delete_dataplane_interface_firewall(interface_name)
    delete_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-interfaces:interfaces/vyatta-interfaces-dataplane:dataplane/"\
      "#{interface_name}/vyatta-security-firewall:firewall"
    response = @controller.rest_agent.delete_request(delete_uri)
    if response.code.to_i == 200
      NetconfResponse.new(NetconfResponseStatus::OK)
    else
      handle_error_response(response)
    end
  end

  ##
  # Get the list of interfaces on the VRouter 5600.
  #
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and list of all interfaces.  
  def get_interfaces_list
    response = get_interfaces_config
    check_response_for_success(response) do |body|
      if body.has_key?('interfaces') && body['interfaces'].is_a?(Hash)
        if_list = []
        body['interfaces'].each do |if_name, interfaces|
          interfaces.each do |interface|
            if_list << interface['tagnode']
          end
        end
        NetconfResponse.new(NetconfResponseStatus::OK, if_list)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end

  ##
  # Return the configuration for the interfaces on the VRouter 5600.
  #
  # _Return_ _Value_
  # * NetconfResponse :  Status ( NetconfResponseStatus ) and configuration for interfaces.  
  def get_interfaces_cfg
    response = get_interfaces_config
    check_response_for_success(response) do |body|
      if body.has_key?('interfaces') && body['interfaces'].is_a?(Hash)
        NetconfResponse.new(NetconfResponseStatus::OK, body)
      else
        NetconfResponse.new(NetconfResponseStatus::DATA_NOT_FOUND)
      end
    end
  end

  private
  
  def get_interfaces_config
    get_uri = "#{@controller.get_ext_mount_config_uri(self)}/"\
      "vyatta-interfaces:interfaces"
    @controller.rest_agent.get_request(get_uri)
  end
end