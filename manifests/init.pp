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
  anchor { 'bind::begin': } ->
  class { 'bind::package': } ->
  class { 'bind::config': } ~>
  class { 'bind::service': } ->
  anchor { 'bind::end': }

  create_resources('bind::resource::acl', $acls)
  create_resources('bind::resource::key', $keys)
  create_resources('bind::resource::zone', $zones)
}

