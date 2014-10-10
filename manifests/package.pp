# == Class: bind::package
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

class bind::package (
  $ensure,
  $packages
) {
  validate_string($ensure)
  validate_re($ensure, '^(present|latest|nstalled|[._0-9a-zA-Z:-]+)$')

  validate_array($packages)

  package { $packages:
    ensure => $ensure
  }
}

