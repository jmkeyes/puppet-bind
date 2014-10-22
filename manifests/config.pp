# == Class: bind::config

class bind::config (
  $owner,
  $group,
  $run_path,
  $base_path,
  $keys_path,
  $config_main,
  $config_local,
  $config_options,
  $dnssec_anchors,
  $purge_configuration,
  $use_rndc_key,
  $rndc_key_name,
  $rndc_key_path,
  $rndc_key_secret,
  $rndc_key_algorithm,
  $use_root_hints,
  $use_default_zones,
  $use_rfc1918_zones,
  $check_names_master   = undef,
  $check_names_slave    = undef,
  $check_names_response = undef,
  $listen_ipv4          = undef,
  $listen_ipv6          = undef,
  $allow_update         = undef,
  $allow_transfer       = undef,
  $allow_notify         = undef,
  $allow_recursion      = undef,
  $allow_query          = undef,
  $forward_policy       = undef,
  $forwarders           = undef
) {
  validate_string($owner)
  validate_string($group)

  validate_absolute_path($run_path)
  validate_absolute_path($base_path)
  validate_absolute_path($keys_path)

  validate_absolute_path($config_main)
  validate_absolute_path($config_local)
  validate_absolute_path($config_options)

  validate_absolute_path($dnssec_anchors)

  validate_bool($purge_configuration)

  validate_bool($use_rndc_key)
  validate_string($rndc_key_name)
  validate_absolute_path($rndc_key_path)
  validate_string($rndc_key_secret)
  validate_string($rndc_key_algorithm)

  validate_bool($use_root_hints)
  validate_bool($use_default_zones)
  validate_bool($use_rfc1918_zones)

  if $check_names_master {
    validate_string($check_names_master)
    validate_re($check_names_master, '^(warn|fail|ignore)$', "\$check_names_master must be one of 'warn', 'fail', or 'ignore'!")
  }

  if $check_names_slave {
    validate_string($check_names_slave)
    validate_re($check_names_slave, '^(warn|fail|ignore)$', "\$check_names_slave must be one of 'warn', 'fail', or 'ignore'!")
  }

  if $check_names_response {
    validate_string($check_names_response)
    validate_re($check_names_response, '^(warn|fail|ignore)$', "\$check_names_response must be one of 'warn', 'fail', or 'ignore'!")
  }

  if $listen_ipv4 {
    validate_array($listen_ipv4)
  }

  if $listen_ipv6 {
    validate_array($listen_ipv6)
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

  if $forward_policy and $forwarders {
    validate_string($forward_policy)
    validate_re($forward_policy, '^(first|only)$', "\$forward_policy must be one of 'first' or 'only'!")
    validate_array($forwarders)
  }

  file { $base_path:
    ensure  => directory,
    recurse => $purge_configuration,
    purge   => $purge_configuration,
    owner   => 'root',
    group   => $group,
    mode    => '0755'
  }

  file { $run_path:
    ensure  => directory,
    recurse => $purge_configuration,
    purge   => $purge_configuration,
    owner   => 'root',
    group   => $group,
    mode    => '0755'
  }

  file { $keys_path:
    ensure  => directory,
    recurse => $purge_configuration,
    purge   => $purge_configuration,
    owner   => $owner,
    group   => $group,
    mode    => '0755'
  }

  file { $config_main:
    ensure  => present,
    content => template("${module_name}/named.conf.erb"),
    owner   => 'root',
    group   => $group,
    mode    => '0644'
  }

  file { $config_options:
    ensure  => present,
    content => template("${module_name}/named.conf.options.erb"),
    owner   => 'root',
    group   => $group,
    mode    => '0644'
  }

  concat { $config_local:
    ensure => present,
    owner  => 'root',
    group  => $group,
    mode   => '0644',
  }

  if $use_rndc_key {
    bind::resource::key { $rndc_key_name:
      ensure    => present,
      algorithm => $rndc_key_algorithm,
      secret    => $rndc_key_secret
    }

    file { $rndc_key_path:
      ensure  => link,
      target  => "${bind::config::keys_path}/${rndc_key_name}.conf",
      require => Bind::Resource::Key[$rndc_key_name]
    }
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
