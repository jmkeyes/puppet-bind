# == Resource: bind::resource::zone
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

define bind::resource::zone (
  $ensure           = present,
  $type             = undef,
  $source           = undef,
  $origin           = $name,
  $allow_update     = undef,
  $allow_notify     = undef,
  $allow_transfer   = undef,
  $masters          = undef,
  $forwarders       = undef,
  $forward_policy   = undef,
  $server_names     = undef,
  $server_addresses = undef,
  $nameservers      = [ $::fqdn ],
) {
  validate_string($name)
  validate_string($origin)

  validate_string($ensure)
  validate_re($ensure, '^(present|absent|)$', "\$ensure must be one of 'absent' or 'present'!")

  validate_string($type)
  validate_re($type, '^(forward||hint|master|slave|stub|static-stub)$', "\$type must be one of 'forward', 'hint', 'master', 'slave', 'stub', or 'static-stub'!")

  if $allow_update {
    validate_array($allow_update)
  }

  if $allow_notify {
    validate_array($allow_notify)
  }

  if $allow_transfer {
    validate_array($allow_transfer)
  }

  if $masters {
    validate_array($masters)
  }

  if $forward_policy and $forwarders {
    validate_string($forward_policy)
    validate_re($forward_policy, '^(first|only)$', "\$forward_policy must be one of 'first' or 'only'!")

    validate_array($forwarders)
  }

  if $server_names {
    validate_array($server_names)
  }

  if $server_addresses {
    validate_array($server_addresses)
  }

  validate_array($nameservers)

  if $source == undef {
    fail('Zone databases without backing source files are currently unsupported.')
  }

  $database = sprintf($::bind::config::zone_database_pattern, $name)

  file { $database:
    ensure       => $ensure,
    validate_cmd => "test '${type}' = 'hint' || /usr/sbin/named-checkzone -q ${name} %",
    owner        => $bind::config::daemon_owner,
    group        => $bind::config::daemon_group,
    source       => $source,
    mode         => '0644'
  }

  concat::fragment { "bind::resource::zone::${name}::config":
    ensure  => $ensure,
    content => template("${module_name}/resource/zone-${type}.conf.erb"),
    target  => $bind::config::local_config_path,
    require => File[$database]
  }
}

