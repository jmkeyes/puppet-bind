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
  $rndc_key_path,
  $bind_keys_file,
  $managed_keys_path,
  $dnssec_enable,
  $dnssec_validation,
  $dnssec_lookaside,
  $purge_configuration,
  $version,
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
  validate_string($owner)
  validate_string($group)

  validate_absolute_path($run_path)
  validate_absolute_path($base_path)
  validate_absolute_path($keys_path)

  validate_absolute_path($config_main)
  validate_absolute_path($config_local)
  validate_absolute_path($config_options)

  validate_absolute_path($rndc_key_path)
  validate_absolute_path($bind_keys_file)
  validate_absolute_path($managed_keys_path)

  validate_string($dnssec_enable)
  validate_re($dnssec_enable, '^(yes|no)$', "\$dnssec_enable must be one of 'yes' or 'no'!")

  validate_string($dnssec_validation)
  validate_re($dnssec_validation, '^(yes|no|auto)$', "\$dnssec_validation must be one of 'yes', 'no' or 'auto'!")

  validate_string($dnssec_lookaside)
  validate_re($dnssec_lookaside, '^(yes|no|auto)$', "\$dnssec_lookaside must be one of 'yes', 'no' or 'auto'!")

  validate_bool($purge_configuration)

  validate_string($version)

  validate_string($use_notify)
  validate_re($use_notify, '^(yes|no)$', "\$use_notify must be one of 'yes' or 'no'!")

  validate_string($use_recursion)
  validate_re($use_recursion, '^(yes|no)$', "\$use_recursion must be one of 'yes' or 'no'!")

  validate_bool($use_default_zones)
  validate_bool($use_rfc1918_zones)

  validate_array($listen_ipv4)
  validate_array($listen_ipv6)

  validate_array($allow_update)
  validate_array($allow_update_forwarding)
  validate_array($allow_transfer)
  validate_array($allow_notify)
  validate_array($allow_recursion)
  validate_array($allow_query)

  validate_string($forward_policy)
  validate_re($forward_policy, '^(first|only)$', "\$forward_policy must be one of 'first' or 'only'!")
  validate_array($forwarders)

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

  file { $managed_keys_path:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => '0755'
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

  file { $bind_keys_file:
    ensure => present,
    source => "puppet:///modules/${module_name}/bind.keys",
    owner  => 'root',
    group  => $group,
    mode   => '0644'
  }

  bind::resource::key{ 'rndc-key':
    ensure    => present,
    secret    => hmac('md5', $::fqdn, $::macaddress),
    algorithm => 'hmac-md5'
  }

  file { $rndc_key_path:
    ensure  => link,
    require => Bind::Resource::Key['rndc-key'],
    target  => "${keys_path}/rndc-key.conf"
  }

  bind::resource::zone { 'root':
    ensure => present,
    source => "puppet:///modules/${module_name}/db.root",
    type   => 'hint',
    zone   => '.'
  }

  if $use_default_zones {
    bind::resource::zone { 'localhost.':
      ensure => present,
      source => "puppet:///modules/${module_name}/db.localhost",
      type   => 'master'
    }

    bind::resource::zone { '0.in-addr.arpa.':
      ensure => present,
      source => "puppet:///modules/${module_name}/db.0",
      type   => 'master'
    }

    bind::resource::zone { '127.in-addr.arpa.':
      ensure => present,
      source => "puppet:///modules/${module_name}/db.127",
      type   => 'master'
    }

    bind::resource::zone { '255.in-addr.arpa.':
      ensure => present,
      source => "puppet:///modules/${module_name}/db.255",
      type   => 'master'
    }
  }

  if $use_rfc1918_zones {
    $rfc1918_zones = [
      '10.in-addr.arpa.',
      '16.172.in-addr.arpa.',
      '17.172.in-addr.arpa.',
      '18.172.in-addr.arpa.',
      '19.172.in-addr.arpa.',
      '20.172.in-addr.arpa.',
      '21.172.in-addr.arpa.',
      '22.172.in-addr.arpa.',
      '23.172.in-addr.arpa.',
      '24.172.in-addr.arpa.',
      '25.172.in-addr.arpa.',
      '26.172.in-addr.arpa.',
      '27.172.in-addr.arpa.',
      '28.172.in-addr.arpa.',
      '29.172.in-addr.arpa.',
      '30.172.in-addr.arpa.',
      '31.172.in-addr.arpa.',
      '168.192.in-addr.arpa.',
    ]

    bind::resource::zone { $rfc1918_zones:
      ensure => present,
      source => "puppet:///modules/${module_name}/db.empty",
      type   => 'master'
    }
  }
}
