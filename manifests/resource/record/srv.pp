# == Define: bind::resource::record::srv

define bind::resource::record::srv (
  $ensure   = present,
  $zone     = undef,
  $owner    = $name,
  $service  = undef,
  $protocol = undef,
  $priority = 0,
  $weight   = 0,
  $port     = undef,
  $target   = undef
) {
  validate_string($name)

  validate_string($zone)
  validate_string($owner)
  validate_string($service)
  validate_string($protocol)
  validate_string($target)

  bind::resource::record { "srv::${name}":
    ensure  => present,
    content => "${priority} ${weight} ${port} ${target}",
    owner   => "_${service}._${protocol}.${owner}",
    zone    => $zone,
    type    => 'SRV',
  }
}
