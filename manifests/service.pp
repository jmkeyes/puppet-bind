# == Class: bind::service
#
# Full description of class bind here.
# 
# === Parameters
# 
# Document parameters here.
# 
# === Examples
#
#
#

class bind::service (
  $services,
  $ensure,
  $enable
) {
  validate_array($services)
  validate_string($ensure)
  validate_re($ensure, '^(running|stopped|[._0-9a-zA-Z:-]+)$')
  validate_bool($enable)

  service { $services:
    ensure => $ensure,
    enable => $enable
  }
}

