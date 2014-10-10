# == Define: bind::resource::record::a

define bind::resource::record::a (
  $ensure = present,
  $zone   = undef,
  $owner  = $name,
  $target = undef
) {
  validate_string($name)

  validate_string($zone)
  validate_string($owner)
  validate_string($target)

  bind::resource::record { "a::${name}":
    ensure  => present,
    content => $target,
    owner   => $owner,
    zone    => $zone,
    type    => 'A',
  }
}
