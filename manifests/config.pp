# == Class: bind::config

class bind::config (
  $daemon_owner,
  $daemon_group,
  $config_directory,
  $working_directory,
  $shared_keys_directory,
  $managed_keys_directory,
  $main_config_path,
  $local_config_path,
  $options_config_path,
  $rndc_key_link,
  $bind_keys_file,
) {
  if $caller_module_name != $module_name {
    fail('Do not include ::bind::config directly!')
  }

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

  $defined_acls  = hiera_hash('bind::acls', {})
  $defined_keys  = hiera_hash('bind::keys', {})
  $defined_zones = hiera_hash('bind::zones', {})

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
    origin => '.'
  }

  if $::bind::use_default_zones {
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

  if $::bind::use_rfc1918_zones {
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

  create_resources('bind::resource::acl', $defined_acls)
  create_resources('bind::resource::key', $defined_keys)
  create_resources('bind::resource::zone', $defined_zones)
}
