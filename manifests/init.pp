# == Class: bind
#
# Full description of class bind here.
#
# === Parameters
#
# Document parameters here.
#
# === Examples
#
# include '::bind'
#

class bind (
  $acls  = {},
  $keys  = {},
  $zones = {}
) {
  if versioncmp($::puppetversion, '3.6.0') < 0 {
    fail('This module requires the use of Puppet v.3.6.0 or newer.')
  }

  contain '::bind::package'
  contain '::bind::config'
  contain '::bind::service'

  Class['::bind::package'] ->
  Class['::bind::config']  ~>
  Class['::bind::service']

  create_resources('bind::resource::acl', $acls)
  create_resources('bind::resource::key', $keys)
  create_resources('bind::resource::zone', $zones)
}

