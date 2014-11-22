# == Class: bind::install

class bind::install {
  if $caller_module_name != $module_name {
    fail('Do not include ::bind::install directly!')
  }

  validate_string($::bind::package_name)

  validate_string($::bind::package_ensure)
  validate_re($::bind::package_ensure, '^(present|latest|nstalled|[._0-9a-zA-Z:-]+)$')

  package { $::bind::package_name:
    ensure => $::bind::package_ensure
  }

  package { 'dnsruby':
    ensure   => present,
    provider => 'gem',
  }
}

