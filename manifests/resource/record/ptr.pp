# == Define: bind::resource::record::ptr

define bind::resource::record::ptr (
  $ensure = present,
  $zone   = undef,
  $owner  = $name,
  $target = undef
) {
  validate_string($name)

  validate_string($zone)
  validate_string($owner)
  validate_string($target)

  bind::resource::record { "ptr::${name}":
    ensure  => present,
    content => $target,
    owner   => $owner,
    zone    => $zone,
    type    => 'PTR',
  }
}
