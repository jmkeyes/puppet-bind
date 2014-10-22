# == Class: bind::service

class bind::service (
  $service_name,
  $service_ensure,
  $service_enable
) {
  validate_string($service_name)

  validate_string($service_ensure)
  validate_re($service_ensure, '^(running|stopped|[._0-9a-zA-Z:-]+)$')

  validate_bool($service_enable)

  service { $service_name:
    ensure => $service_ensure,
    enable => $service_enable
  }
}

