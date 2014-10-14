# == Class: bind::config
#
# This class manages the BIND server configuration.
#
# === Parameters
#
# Document parameters here.
#

class bind::config (
  $owner,
  $group,
  $keys_path,
  $zones_path,
  $config_path,
  $config_main,
  $config_local,
  $config_options,
  $config_controls,
  $purge_configs,
  $rndc_key_path,
  $use_root_hints,
  $use_default_zones,
  $use_rfc1918_zones,
  $check_names_master,
  $check_names_slave,
  $check_names_response,
  $default_forwarders = undef,
  $allow_update       = undef,
  $allow_transfer     = undef,
  $allow_notify       = undef,
  $allow_recursion    = undef,
  $allow_query        = undef
) {
  validate_string($owner)
  validate_string($group)

  validate_bool($purge_configs)

  validate_absolute_path($config_path)
  validate_absolute_path($config_main)
  validate_absolute_path($config_local)
  validate_absolute_path($config_options)
  validate_absolute_path($config_controls)

  validate_absolute_path($rndc_key_path)

  validate_string($check_names_master)
  validate_re($check_names_master, '^(warn|fail|ignore)$', "\$check_names_master must be one of 'warn', 'fail', or 'ignore'!")

  validate_string($check_names_slave)
  validate_re($check_names_slave, '^(warn|fail|ignore)$', "\$check_names_slave must be one of 'warn', 'fail', or 'ignore'!")

  validate_string($check_names_response)
  validate_re($check_names_response, '^(warn|fail|ignore)$', "\$check_names_response must be one of 'warn', 'fail', or 'ignore'!")

  if $default_forwarders {
    validate_array($default_forwarders)
  }

  if $allow_update {
    validate_array($allow_update)
  }

  if $allow_transfer {
    validate_array($allow_transfer)
  }

  if $allow_notify {
    validate_array($allow_notify)
  }

  if $allow_recursion {
    validate_array($allow_recursion)
  }

  if $allow_query {
    validate_array($allow_query)
  }

  file { $config_path:
    ensure  => directory,
    recurse => $purge_configs,
    purge   => $purge_configs,
    owner   => $owner,
    group   => $group,
    mode    => '0755'
  }

  file { [ $keys_path, $zones_path ]:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => '0755'
  }

  file { $config_main:
    ensure  => present,
    content => template("${module_name}/named.conf.erb"),
    require => File[$config_path],
    owner   => $owner,
    group   => $group,
    mode    => '0644'
  }

  concat { $config_local:
    ensure  => present,
    require => File[$config_path],
    owner   => $owner,
    group   => $group,
    mode    => '0644',
  }

  file { $config_options:
    ensure  => present,
    content => template("${module_name}/named.conf.options.erb"),
    require => File[$config_path],
    owner   => $owner,
    group   => $group,
    mode    => '0644'
  }

  file { $rndc_key_path:
    ensure  => link,
    target  => "${bind::config::keys_path}/rndc-key.conf",
    require => Bind::Resource::Key['rndc-key']
  }

  file { $config_controls:
    ensure  => present,
    content => template("${module_name}/named.conf.controls.erb"),
    require => File[$config_path],
    owner   => $owner,
    group   => $group,
    mode    => '0644'
  }

  bind::resource::key { 'rndc-key':
    ensure    => present,
    secret    => hmac('md5', $::fqdn, $::macaddress),
    algorithm => 'hmac-md5'
  }

  if $use_root_hints {
    bind::resource::zone { 'root':
      ensure => present,
      source => "puppet:///modules/${module_name}/db.root",
      type   => 'hint'
    }
  }

  if $use_default_zones {
    bind::resource::zone { 'localhost':
      ensure => present,
      source => "puppet:///modules/${module_name}/db.localhost",
      type   => 'master'
    }

    bind::resource::zone { '0.in-addr.arpa':
      ensure => present,
      source => "puppet:///modules/${module_name}/db.0",
      type   => 'master'
    }

    bind::resource::zone { '127.in-addr.arpa':
      ensure => present,
      source => "puppet:///modules/${module_name}/db.127",
      type   => 'master'
    }

    bind::resource::zone { '255.in-addr.arpa':
      ensure => present,
      source => "puppet:///modules/${module_name}/db.255",
      type   => 'master'
    }
  }

  if $use_rfc1918_zones {
    $rfc1918_zones = [
      '10.in-addr.arpa',
      '16.172.in-addr.arpa',
      '17.172.in-addr.arpa',
      '18.172.in-addr.arpa',
      '19.172.in-addr.arpa',
      '20.172.in-addr.arpa',
      '21.172.in-addr.arpa',
      '22.172.in-addr.arpa',
      '23.172.in-addr.arpa',
      '24.172.in-addr.arpa',
      '25.172.in-addr.arpa',
      '26.172.in-addr.arpa',
      '27.172.in-addr.arpa',
      '28.172.in-addr.arpa',
      '29.172.in-addr.arpa',
      '30.172.in-addr.arpa',
      '31.172.in-addr.arpa',
      '168.192.in-addr.arpa',
    ]

    bind::resource::zone { $rfc1918_zones:
      ensure => present,
      source => "puppet:///modules/${module_name}/db.empty",
      type   => 'master'
    }
  }
}
