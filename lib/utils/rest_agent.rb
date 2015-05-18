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

class RestAgent #:nodoc: all
  require 'uri'
  require 'net/http'
  require 'logger'

  attr_reader :service_uri
  attr_accessor :headers
  
  $LOG = Logger.new('rubybvc-requests.log')

  def initialize(service_uri, headers: {}, username: nil, password: nil,
      open_timeout: nil)
    @service_uri = URI(service_uri)
    @headers = {'Content-Type' => 'application/json', 'Accept' => 'application/json'}.merge(headers)
    @username = username
    @password = password
    @open_timeout = open_timeout
  end
  
  def get_request(uri_endpoint, query_params = {})
    uri = @service_uri + URI(uri_endpoint)
    uri.query = URI.encode_www_form(query_params) unless query_params.empty?
    req = Net::HTTP::Get.new(uri, @headers)
    return send_request(uri, req)
  end

  def post_request(uri_endpoint, post_body, headers: {})
    uri = @service_uri + URI(uri_endpoint)
    req = Net::HTTP::Post.new(uri, @headers.merge(headers))
    req.body = post_body.is_a?(String) ? post_body : post_body.to_json
    return send_request(uri, req)
  end
  
#  def patch_request(uri_endpoint, patch_body, headers: {})
#    uri = @service_uri + URI(uri_endpoint)
#    req = Net::HTTP::Patch.new(uri, @headers.merge(headers))
#    req.body = patch_body.to_json
#    return send_request(uri, req)
#  end

  def put_request(uri_endpoint, put_body, headers: {})
    uri = @service_uri + URI(uri_endpoint)
    req = Net::HTTP::Put.new(uri, @headers.merge(headers))
    req.body = put_body.to_json
    return send_request(uri, req)
  end

  def delete_request(uri_endpoint)
    uri = @service_uri + URI(uri_endpoint)
    req = Net::HTTP::Delete.new(uri, @headers)
    return send_request(uri, req)
  end

  private

  def send_request(uri, request)
    request.basic_auth(@username, @password) unless @username.nil? || @username.empty?
    begin
      $LOG.info request.to_yaml
      response =  Net::HTTP.start(uri.host, uri.port, :open_timeout => @open_timeout,
        :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
      end
      $LOG.info response.to_yaml
      # catch html responses
      return response
    rescue Net::HTTPHeaderSyntaxError, Net::HTTPBadResponse, Net::OpenTimeout => e
      $LOG.error "Error connecting to #{@service_uri}: #{e.message}"
      return nil
    end
  end

end