# == Define: bind::resource::record::soa

define bind::resource::record::soa (
  $ensure   = present,
  $zone     = undef,
  $owner    = $name,
  $mname    = "${::fqdn}.",
  $rname    = "hostmaster.${::fqdn}.",
  $serial   = 0,
  $_refresh = 86400,
  $retry    = 86400,
  $expiry   = 2419200,
  $nx_ttl   = 3600
) {
  validate_string($name)

  validate_string($zone)
  validate_string($owner)
  validate_string($mname)
  validate_string($rname)

  if $serial == 0 {
    $serial_real = strftime('%Y%m%d%H')
  } else {
    $serial_real = $serial
  }

  bind::resource::record { "soa::${name}":
    ensure  => present,
    content => "${mname} ${rname} (${serial_real} ${_refresh} ${retry} ${expiry} ${nx_ttl})",
    owner   => $owner,
    zone    => $zone,
    type    => 'SOA',
    order   => 20
  }
}
