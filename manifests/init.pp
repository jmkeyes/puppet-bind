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
  $package_name,
  $package_ensure,
  $service_name,
  $service_ensure,
  $service_enable,
  $service_manage,
  $purge_configuration,
  $dnssec_enable,
  $dnssec_validation,
  $dnssec_lookaside,
  $check_names_master,
  $check_names_slave,
  $check_names_response,
  $use_notify,
  $use_recursion,
  $use_default_zones,
  $use_rfc1918_zones,
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
  $forward_policy,
  $forwarders,
) {
  # Fail fast if we're not using a new Puppet version.
  if versioncmp($::puppetversion, '3.6.0') < 0 {
    fail('This module requires the use of Puppet v.3.6.0 or newer.')
  }

  validate_bool($::bind::purge_configuration)

  validate_string($::bind::dnssec_enable)
  validate_string($::bind::dnssec_validation)
  validate_string($::bind::dnssec_lookaside)

  validate_re($::bind::dnssec_enable, '^(yes|no)$', "\$dnssec_enable must be one of 'yes' or 'no'!")
  validate_re($::bind::dnssec_validation, '^(yes|no|auto)$', "\$dnssec_validation must be one of 'yes', 'no' or 'auto'!")
  validate_re($::bind::dnssec_lookaside, '^(yes|no|auto)$', "\$dnssec_lookaside must be one of 'yes', 'no' or 'auto'!")

  validate_string($::bind::check_names_master)
  validate_string($::bind::check_names_slave)
  validate_string($::bind::check_names_response)

  validate_re($::bind::check_names_master, '^(none|warn|fail|ignore)$', "\$check_names_master must be one of 'none', 'warn', 'fail', or 'ignore'!")
  validate_re($::bind::check_names_slave, '^(none|warn|fail|ignore)$', "\$check_names_slave must be one of 'none', 'warn', 'fail', or 'ignore'!")
  validate_re($::bind::check_names_response, '^(none|warn|fail|ignore)$', "\$check_names_response must be one of 'none', 'warn', 'fail', or 'ignore'!")

  validate_string($::bind::use_notify)
  validate_string($::bind::use_recursion)

  validate_re($::bind::use_notify, '^(yes|no)$', "\$use_notify must be one of 'yes' or 'no'!")
  validate_re($::bind::use_recursion, '^(yes|no)$', "\$use_recursion must be one of 'yes' or 'no'!")

  validate_bool($::bind::use_default_zones)
  validate_bool($::bind::use_rfc1918_zones)

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

  validate_string($::bind::forward_policy)
  validate_re($::bind::forward_policy, '^(first|only)$', "\$forward_policy must be one of 'first' or 'only'!")

  validate_array($::bind::forwarders)

  contain '::bind::install'
  contain '::bind::config'
  contain '::bind::service'

  Class['::bind::install'] ->
  Class['::bind::config']  ~>
  Class['::bind::service']
}

