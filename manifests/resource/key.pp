# == Resource: bind::resource::key
#
# Copyright 2016 Joshua M. Keyes <joshua.michael.keyes@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

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
  $ensure    = present,
  $algorithm = undef,
  $secret    = undef,
) {
  validate_string($name)

  validate_string($secret)
  validate_re($secret, '^[a-zA-Z0-9+/]+={0,2}$', "\$secret must be a Base64 encoded string!")

  validate_string($ensure)
  validate_re($ensure, '^(present|absent|)$', "\$ensure must be one of 'absent' or 'present'!")

  validate_string($algorithm)
  validate_re($algorithm, '^hmac-(md5|sha(1|224|256|384|512))$', "\$algorithm must be either HMAC-MD5 or in the HMAC-SHA(1-512) family!")

  $key_conf_file = "${bind::config::keys_directory}/${name}.conf"

  file { $key_conf_file:
    ensure       => $ensure,
    content      => template("${module_name}/resource/key.conf.erb"),
    require      => File[$bind::config::keys_directory],
    validate_cmd => $::bind::config::validate_cmd,
    owner        => $bind::config::daemon_owner,
    group        => $bind::config::daemon_group,
    mode         => '0600'
  }

  concat::fragment { "bind::resource::key::${name}":
    ensure  => $ensure,
    target  => $bind::config::local_config_path,
    content => "include \"${key_conf_file}\";\n",
    require => File[$key_conf_file],
  }
}

