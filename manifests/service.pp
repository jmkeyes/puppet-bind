# == Class: bind::service

class bind::service {
  if $caller_module_name != $module_name {
    fail('Do not include ::bind::service directly!')
  }

  validate_string($::bind::service_name)

  validate_string($::bind::service_ensure)
  validate_re($::bind::service_ensure, '^(running|stopped|[._0-9a-zA-Z:-]+)$')

  validate_bool($::bind::service_enable)

  validate_bool($::bind::service_manage)

  if $::bind::service_manage {
    service { $::bind::service_name:
      ensure     => $::bind::service_ensure,
      enable     => $::bind::service_enable,
      hasstatus  => true,
      hasrestart => true
    }
  }
}

