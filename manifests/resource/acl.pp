# == Resource: bind::resource::acl

define bind::resource::acl (
  $ensure    = undef,
  $addresses = undef
) {
  validate_string($name)

  validate_string($ensure)
  validate_re($ensure, '^(present|absent|)$', "\$ensure must be one of 'absent' or 'present'!")

  validate_array($addresses)

  concat::fragment { "bind::resource::acl::${name}":
    ensure  => $ensure,
    content => template("${module_name}/resource/acl.conf.erb"),
    target  => $bind::config::config_local
  }
}

