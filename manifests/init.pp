# == Class: bind
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
  $dnssec_enable,
  $dnssec_validation,
  $dnssec_lookaside,
  $purge_configuration,
  $use_notify,
  $use_recursion,
  $use_default_zones,
  $use_rfc1918_zones,
  $listen_ipv4,
  $listen_ipv6,
  $allow_update,
  $allow_update_forwarding,
  $allow_transfer,
  $allow_notify,
  $allow_recursion,
  $allow_query,
  $forward_policy,
  $forwarders,
) {
  if versioncmp($::puppetversion, '3.6.0') < 0 {
    fail('This module requires the use of Puppet v.3.6.0 or newer.')
  }

  contain '::bind::install'
  contain '::bind::config'
  contain '::bind::service'

  Class['::bind::install'] ->
  Class['::bind::config']  ~>
  Class['::bind::service']

  $acls  = hiera_hash('bind::acls', {})
  $keys  = hiera_hash('bind::keys', {})
  $zones = hiera_hash('bind::zones', {})

  create_resources('bind::resource::acl', $acls)
  create_resources('bind::resource::key', $keys)
  create_resources('bind::resource::zone', $zones)
}

