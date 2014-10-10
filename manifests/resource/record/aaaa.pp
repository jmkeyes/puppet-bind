# == Define: bind::resource::record::aaaa

define bind::resource::record::aaaa (
  $ensure = present,
  $zone   = undef,
  $owner  = $name,
  $target = undef
) {
  validate_string($name)

  validate_string($zone)
  validate_string($owner)
  validate_string($target)

  bind::resource::record { "aaaa::${name}":
    ensure  => present,
    content => $target,
    owner   => $owner,
    zone    => $zone,
    type    => 'AAAA',
  }
}
