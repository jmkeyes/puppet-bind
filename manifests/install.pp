# == Class: bind::install

class bind::install (
  $package_name,
  $package_ensure,
) {
  if $caller_module_name != $module_name {
    fail('Do not include ::bind::install directly!')
  }

  validate_string($bind::install::package_name)

  validate_string($bind::install::package_ensure)
  validate_re($bind::install::package_ensure, '^(present|latest|nstalled|[._0-9a-zA-Z:-]+)$')

  package { $bind::install::package_name:
    ensure => $bind::install::package_ensure
  }
}

