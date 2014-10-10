# == Define: bind::resource::record::ns

define bind::resource::record::ns (
  $ensure = present,
  $zone   = undef,
  $owner  = $name,
  $target = undef
) {
  validate_string($name)

  validate_string($zone)
  validate_string($owner)
  validate_string($target)

  bind::resource::record { "ns::${name}":
    ensure  => present,
    content => $target,
    owner   => $owner,
    zone    => $zone,
    type    => 'NS',
  }
}
