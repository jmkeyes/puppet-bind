# == Class: bind::service

class bind::service (
  $service_name,
  $service_ensure,
  $service_enable
) {
  private('Do not include ::bind::service directly!')

  validate_string($bind::service::service_name)

  validate_string($bind::service::service_ensure)
  validate_re($bind::service::service_ensure, '^(running|stopped|[._0-9a-zA-Z:-]+)$')

  validate_bool($bind::service::service_enable)

  service { $bind::service::service_name:
    ensure => $bind::service::service_ensure,
    enable => $bind::service::service_enable
  }
}

