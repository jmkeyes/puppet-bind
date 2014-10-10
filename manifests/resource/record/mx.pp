# == Define: bind::resource::record::mx

define bind::resource::record::mx (
  $ensure     = present,
  $zone       = undef,
  $owner      = $name,
  $target     = undef,
  $preference = 10
) {
  validate_string($name)

  validate_string($zone)
  validate_string($owner)
  validate_string($target)

  bind::resource::record { "mx::${name}":
    ensure  => present,
    content => "${preference} ${target}",
    owner   => $owner,
    zone    => $zone,
    type    => 'MX',
  }
}
