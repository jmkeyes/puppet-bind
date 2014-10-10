# == Define: bind::resource::record::cname

define bind::resource::record::cname (
  $ensure = present,
  $zone   = undef,
  $owner  = $name,
  $target = undef
) {
  validate_string($name)

  validate_string($zone)
  validate_string($owner)
  validate_string($target)

  bind::resource::record { "cname::${name}":
    ensure  => present,
    content => $target,
    type    => 'CNAME',
    owner   => $owner,
    zone    => $zone
  }
}
