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

require 'openflowdev/actions/action'
require 'openflowdev/actions/copy_ttl_inwards_action'
require 'openflowdev/actions/copy_ttl_outwards_action'
require 'openflowdev/actions/dec_mpls_ttl_action'
require 'openflowdev/actions/dec_nw_ttl_action'
require 'openflowdev/actions/drop_action'
require 'openflowdev/actions/flood_action'
require 'openflowdev/actions/flood_all_action'
require 'openflowdev/actions/group_action'
require 'openflowdev/actions/hw_path_action'
require 'openflowdev/actions/loopback_action'
require 'openflowdev/actions/output_action'
require 'openflowdev/actions/pop_mpls_header_action'
require 'openflowdev/actions/pop_pbb_header_action'
require 'openflowdev/actions/pop_vlan_header_action'
require 'openflowdev/actions/push_mpls_header_action'
require 'openflowdev/actions/push_pbb_header_action'
require 'openflowdev/actions/push_vlan_header_action'
require 'openflowdev/actions/set_dl_dst_action'
require 'openflowdev/actions/set_dl_src_action'
require 'openflowdev/actions/set_field_action'
require 'openflowdev/actions/set_mpls_ttl_action'
require 'openflowdev/actions/set_nw_dst_action'
require 'openflowdev/actions/set_nw_src_action'
require 'openflowdev/actions/set_nw_ttl_action'
require 'openflowdev/actions/set_queue_action'
require 'openflowdev/actions/set_tp_dst_action'
require 'openflowdev/actions/set_tp_src_action'
require 'openflowdev/actions/set_vlan_cfi_action'
require 'openflowdev/actions/set_vlan_id_action'
require 'openflowdev/actions/set_vlan_pcp_action'
require 'openflowdev/actions/strip_vlan_action'
require 'openflowdev/actions/sw_path_action'