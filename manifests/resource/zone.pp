# == Resource: bind::resource::zone

define bind::resource::zone (
  $ensure         = present,
  $type           = undef,
  $source         = undef,
  $overwrite      = false,
  $allow_update   = undef,
  $allow_notify   = undef,
  $allow_transfer = undef,
  $masters        = undef,
  $forwarders     = undef,
  $forward_policy = undef,
  $nameserver     = $::fqdn,
) {
  validate_string($name)

  validate_string($ensure)
  validate_re($ensure, '^(present|absent|)$', "\$ensure must be one of 'absent' or 'present'!")

  validate_string($type)
  validate_re($type, '^(forward||hint|master|slave|stub)$', "\$type must be one of 'forward', 'hint', 'master', 'slave', or 'stub'!")

  if $allow_update {
    validate_array($allow_update)
  }

  if $allow_notify {
    validate_array($allow_notify)
  }

  if $allow_transfer {
    validate_array($allow_transfer)
  }

  if $masters {
    validate_array($masters)
  }

  if $forward_policy and $forwarders {
    validate_string($forward_policy)
    validate_re($forward_policy, '^(first|only)$', "\$forward_policy must be one of 'first' or 'only'!")

    validate_array($forwarders)
  }

  $database = "${bind::config::zones_path}/db.${name}"

  if $source {
    file { $database:
      ensure => $ensure,
      owner  => $bind::config::owner,
      group  => $bind::config::group,
      source => $source
    }
  } else {
    concat { $database:
      ensure  => $ensure,
      require => Class['concat::setup'],
      owner   => $bind::config::owner,
      group   => $bind::config::group,
      replace => $overwrite,
      mode    => '0644'
    }

    concat::fragment { "bind::resource::zone::${name}::header":
      ensure  => $ensure,
      content => template("${module_name}/resource/database-header.erb"),
      target  => $database,
      order   => 10,
    }

    bind::resource::record::soa { $name:
      ensure => $ensure,
      mname  => $nameserver,
      owner  => $name
    }

    concat::fragment { "bind::resource::zone::${name}::footer":
      ensure  => $ensure,
      content => template("${module_name}/resource/database-footer.erb"),
      target  => $database,
      order   => 90,
    }
  }

  concat::fragment { "bind::resource::zone::${name}::config":
    ensure  => $ensure,
    content => template("${module_name}/resource/zone-${type}.conf.erb"),
    target  => $bind::config::config_local,
    require => File[$database]
  }
}

