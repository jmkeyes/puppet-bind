# == Class: bind::config

class bind::config (
  $daemon_owner,
  $daemon_group,
  $config_directory,
  $working_directory,
  $main_config_path,
  $local_config_path,
  $options_config_path,
  $shared_keys_directory,
  $managed_keys_directory,
  $rndc_key_link,
  $bind_keys_file,
) {
  private('Do not include ::bind::config directly!')

  validate_string($::bind::config::daemon_owner)
  validate_string($::bind::config::daemon_group)

  validate_absolute_path($::bind::config::working_directory)
  validate_absolute_path($::bind::config::config_directory)

  validate_absolute_path($::bind::config::shared_keys_directory)
  validate_absolute_path($::bind::config::managed_keys_directory)

  validate_absolute_path($::bind::config::main_config_path)
  validate_absolute_path($::bind::config::local_config_path)
  validate_absolute_path($::bind::config::options_config_path)

  validate_absolute_path($::bind::config::rndc_key_link)
  validate_absolute_path($::bind::config::bind_keys_file)

  validate_string($::bind::dnssec_enable)
  validate_re($::bind::dnssec_enable, '^(yes|no)$', "\$dnssec_enable must be one of 'yes' or 'no'!")

  validate_string($::bind::dnssec_validation)
  validate_re($::bind::dnssec_validation, '^(yes|no|auto)$', "\$dnssec_validation must be one of 'yes', 'no' or 'auto'!")

  validate_string($::bind::dnssec_lookaside)
  validate_re($::bind::dnssec_lookaside, '^(yes|no|auto)$', "\$dnssec_lookaside must be one of 'yes', 'no' or 'auto'!")

  validate_bool($::bind::purge_configuration)

  validate_string($::bind::check_names_master)
  validate_re($::bind::check_names_master, '^(none|warn|fail|ignore)$', "\$check_names_master must be one of 'none', 'warn', 'fail', or 'ignore'!")

  validate_string($::bind::check_names_slave)
  validate_re($::bind::check_names_slave, '^(none|warn|fail|ignore)$', "\$check_names_slave must be one of 'none', 'warn', 'fail', or 'ignore'!")

  validate_string($::bind::check_names_response)
  validate_re($::bind::check_names_response, '^(none|warn|fail|ignore)$', "\$check_names_response must be one of 'none', 'warn', 'fail', or 'ignore'!")

  validate_string($::bind::version)

  validate_string($::bind::use_notify)
  validate_re($::bind::use_notify, '^(yes|no)$', "\$use_notify must be one of 'yes' or 'no'!")

  validate_string($::bind::use_recursion)
  validate_re($::bind::use_recursion, '^(yes|no)$', "\$use_recursion must be one of 'yes' or 'no'!")

  validate_bool($::bind::use_default_zones)
  validate_bool($::bind::use_rfc1918_zones)

  validate_array($::bind::listen_ipv4)
  validate_array($::bind::listen_ipv6)

  validate_array($::bind::allow_update)
  validate_array($::bind::allow_update_forwarding)
  validate_array($::bind::allow_transfer)
  validate_array($::bind::allow_notify)
  validate_array($::bind::allow_recursion)
  validate_array($::bind::allow_query)

  validate_string($::bind::forward_policy)
  validate_re($::bind::forward_policy, '^(first|only)$', "\$forward_policy must be one of 'first' or 'only'!")
  validate_array($::bind::forwarders)

  file { $::bind::config::config_directory:
    ensure  => directory,
    recurse => $::bind::purge_configuration,
    purge   => $::bind::purge_configuration,
    owner   => 'root',
    group   => $::bind::config::daemon_group,
    mode    => '0755'
  }

  file { $::bind::config::working_directory:
    ensure  => directory,
    recurse => $::bind::purge_configuration,
    purge   => $::bind::purge_configuration,
    owner   => 'root',
    group   => $::bind::config::daemon_group,
    mode    => '0755'
  }

  file { $::bind::config::shared_keys_directory:
    ensure  => directory,
    recurse => $::bind::purge_configuration,
    purge   => $::bind::purge_configuration,
    owner   => $::bind::config::daemon_owner,
    group   => $::bind::config::daemon_group,
    mode    => '0755'
  }

  file { $::bind::config::managed_keys_directory:
    ensure => directory,
    owner  => $::bind::config::daemon_owner,
    group  => $::bind::config::daemon_group,
    mode   => '0755'
  }

  file { $::bind::config::main_config_path:
    ensure  => present,
    content => template("${module_name}/named.conf.erb"),
    owner   => 'root',
    group   => $::bind::config::daemon_group,
    mode    => '0644'
  }

  file { $::bind::config::options_config_path:
    ensure  => present,
    content => template("${module_name}/named.conf.options.erb"),
    owner   => 'root',
    group   => $::bind::config::daemon_group,
    mode    => '0644'
  }

  concat { $::bind::config::local_config_path:
    ensure => present,
    owner  => 'root',
    group  => $::bind::config::daemon_group,
    mode   => '0644',
  }

  file { $::bind::config::bind_keys_file:
    ensure => present,
    source => "puppet:///modules/${module_name}/bind.keys",
    owner  => 'root',
    group  => $::bind::config::daemon_group,
    mode   => '0644'
  }

  bind::resource::key { 'rndc-key':
    ensure    => present,
    secret    => hmac('md5', $::fqdn, $::macaddress),
    algorithm => 'hmac-md5'
  }

  file { $::bind::config::rndc_key_link:
    ensure  => link,
    target  => "${::bind::config::shared_keys_directory}/rndc-key.conf",
    require => Bind::Resource::Key['rndc-key']
  }

  bind::resource::zone { 'root':
    ensure => present,
    source => "puppet:///modules/${module_name}/db.root",
    type   => 'hint',
    zone   => '.'
  }

  if $::bind::use_default_zones {
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

  if $::bind::use_rfc1918_zones {
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
