# == Class: bind
#
# Copyright 2016 Joshua M. Keyes <joshua.michael.keyes@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Full description of class bind here.
#
# === Parameters
#
# Document parameters here.
#
# === Examples
#
# include '::bind'
#

class bind (
  $package_name,
  $package_ensure,
  $service_name,
  $service_ensure,
  $service_enable,
  $service_manage,
  $purge_configuration,
  $use_rndc_key,
  $use_rndc_config,
  $dnssec_enable,
  $dnssec_validation,
  $dnssec_lookaside,
  $use_notify,
  $use_recursion,
  $listen_ipv4,
  $listen_ipv6,
  $avoid_v4_udp_ports,
  $avoid_v6_udp_ports,
  $allow_update,
  $allow_update_forwarding,
  $allow_transfer,
  $allow_notify,
  $allow_recursion,
  $allow_query,
  $allow_query_cache,
  $forward_policy,
  $forwarders,
  $rndc_key_secret = hmac('md5', $::fqdn, $::macaddress),
) {
  # Fail fast if we're not using a new Puppet version.
  if versioncmp($::puppetversion, '3.6.0') < 0 {
    fail('This module requires the use of Puppet v.3.6.0 or newer.')
  }

  validate_bool($::bind::purge_configuration)

  validate_bool($::bind::use_rndc_key)
  validate_bool($::bind::use_rndc_config)

  validate_string($::bind::dnssec_enable)
  validate_string($::bind::dnssec_validation)
  validate_string($::bind::dnssec_lookaside)

  validate_re($::bind::dnssec_enable, '^(yes|no)$', "\$dnssec_enable must be one of 'yes' or 'no'!")
  validate_re($::bind::dnssec_validation, '^(yes|no|auto)$', "\$dnssec_validation must be one of 'yes', 'no' or 'auto'!")
  validate_re($::bind::dnssec_lookaside, '^(yes|no|auto)$', "\$dnssec_lookaside must be one of 'yes', 'no' or 'auto'!")

  validate_string($::bind::use_notify)
  validate_string($::bind::use_recursion)

  validate_re($::bind::use_notify, '^(yes|no)$', "\$use_notify must be one of 'yes' or 'no'!")
  validate_re($::bind::use_recursion, '^(yes|no)$', "\$use_recursion must be one of 'yes' or 'no'!")

  validate_array($::bind::listen_ipv4)
  validate_array($::bind::listen_ipv6)

  validate_array($::bind::avoid_v4_udp_ports)
  validate_array($::bind::avoid_v6_udp_ports)

  validate_array($::bind::allow_update)
  validate_array($::bind::allow_update_forwarding)
  validate_array($::bind::allow_transfer)
  validate_array($::bind::allow_notify)
  validate_array($::bind::allow_recursion)
  validate_array($::bind::allow_query)
  validate_array($::bind::allow_query_cache)

  validate_string($::bind::forward_policy)
  validate_re($::bind::forward_policy, '^(first|only)$', "\$forward_policy must be one of 'first' or 'only'!")

  validate_array($::bind::forwarders)

  validate_string($::bind::rndc_key_secret)

  contain '::bind::install'
  contain '::bind::config'
  contain '::bind::service'

  Class['::bind::install'] ->
  Class['::bind::config']  ~>
  Class['::bind::service']
}

