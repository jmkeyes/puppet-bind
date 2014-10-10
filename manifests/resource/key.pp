# == Resource: bind::resource::key
#
# The following resource definition:
#
#    bind::resource::key { 'ddns-update':
#      secret    => "IDCAq2eNMnZDcM9X9haDyg==",
#      algorithm => 'hmac-md5',
#      ensure    => present,
#    }
#
# Should create /etc/bind/bind.keys.d/ddns-update.conf containing:
#
#    key "ddns-update" {
#      algorithm hmac-md5;
#      secret "IDCAq2eNMnZDcM9X9haDyg==";
#    };
#
# Check out `ddns-confgen` for more options.
#

define bind::resource::key (
  $secret,
  $ensure     = undef,
  $algorithm  = undef,
) {
  validate_string($name)

  validate_string($secret)
  validate_re($secret, '^[a-zA-Z0-9+/]+={0,2}$', "\$secret must be a Base64 encoded string!")

  validate_string($ensure)
  validate_re($ensure, '^(present|absent|)$', "\$ensure must be one of 'absent' or 'present'!")

  validate_string($algorithm)
  validate_re($algorithm, '^hmac-(md5|sha(1|224|256|384|512))$', "\$algorithm must be either HMAC-MD5 or in the HMAC-SHA(1-512) family!")

  $key_conf_file = "${bind::config::keys_path}/${name}.conf"

  file { $key_conf_file:
    ensure  => $ensure,
    content => template("${module_name}/resource/key.conf.erb"),
    require => File[$bind::config::keys_path],
    owner   => $bind::config::owner,
    group   => $bind::config::group,
    mode    => '0640'
  }

  concat::fragment { "bind::resource::key::${name}":
    ensure  => $ensure,
    target  => $bind::config::config_local,
    content => "include \"${key_conf_file}\";\n",
    require => File[$key_conf_file],
  }
}

