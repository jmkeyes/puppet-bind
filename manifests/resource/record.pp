# == Resource: bind::resource::record

define bind::resource::record (
  $ensure  = present,
  $zone    = undef,
  $ttl     = 86400,
  $type    = undef,
  $content = undef,
  $order   = 30,
) {
  validate_string($name)

  validate_string($ensure)
  validate_re($ensure, '^(present|absent|)$', "\$ensure must be one of 'absent' or 'present'!")

  validate_string($zone)
  validate_string($type)
  validate_string($content)

  concat::fragment { "bind::resource::zone::${zone}::record::${name}":
    ensure  => $ensure,
    content => template("${module_name}/resource/record.erb"),
    target  => "${bind::config::zones_path}/db.${zone}",
    order   => $order
  }
}
