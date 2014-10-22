# == Class: bind::install

class bind::install (
  $package_name,
  $package_ensure,
) {
  validate_string($package_name)

  validate_string($package_ensure)
  validate_re($package_ensure, '^(present|latest|nstalled|[._0-9a-zA-Z:-]+)$')

  package { $package_name:
    ensure => $package_ensure
  }
}

