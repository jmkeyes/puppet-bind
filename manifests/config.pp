# == Class: bind::config
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

class bind::config (
  $daemon_owner,
  $daemon_group,
  $config_directory,
  $working_directory,
  $keys_directory,
  $bind_keys_file,
  $main_config_path,
  $local_config_path,
  $options_config_path,
  $dump_cache_file,
  $statistics_file,
  $memstatistics_file,
  $rndc_key_path,
  $rndc_config_path,
  $zone_database_pattern,
) {
  if $caller_module_name != $module_name {
    fail('Do not include ::bind::config directly!')
  }

  validate_string($::bind::config::daemon_owner)
  validate_string($::bind::config::daemon_group)

  validate_absolute_path($::bind::config::working_directory)
  validate_absolute_path($::bind::config::config_directory)

  validate_absolute_path($::bind::config::keys_directory)
  validate_absolute_path($::bind::config::bind_keys_file)

  validate_absolute_path($::bind::config::main_config_path)
  validate_absolute_path($::bind::config::local_config_path)
  validate_absolute_path($::bind::config::options_config_path)

  validate_absolute_path($::bind::config::dump_cache_file)
  validate_absolute_path($::bind::config::statistics_file)
  validate_absolute_path($::bind::config::memstatistics_file)

  validate_absolute_path($::bind::config::rndc_key_path)
  validate_absolute_path($::bind::config::rndc_config_path)

  validate_string($::bind::config::zone_database_pattern)

  ### Manage the BIND system group.
  group { $::bind::config::daemon_group:
    ensure => present
  }

  ### Manage the BIND system user.
  user { $::bind::config::daemon_owner:
    ensure   => present,
    home     => $::bind::config::working_directory,
    expiry   => absent,
    system   => true,
    password => '*'
  }

  ### Create necessary directories.
  file {
    $::bind::config::config_directory:
      ensure => directory,
      group   => $::bind::config::daemon_group,
      purge   => $::bind::purge_configuration,
      recurse => $::bind::purge_configuration,
      force   => $::bind::purge_configuration,
      owner  => 'root',
      mode   => '0750';
    $::bind::config::working_directory:
      ensure => directory,
      group   => $::bind::config::daemon_group,
      purge   => $::bind::purge_configuration,
      recurse => $::bind::purge_configuration,
      force   => $::bind::purge_configuration,
      owner  => 'root',
      mode   => '0750';
    $::bind::config::keys_directory:
      ensure => directory,
      group   => $::bind::config::daemon_group,
      purge   => $::bind::purge_configuration,
      recurse => $::bind::purge_configuration,
      force   => $::bind::purge_configuration,
      mode   => '0750';
  }

  ### Create named.conf configuration file.
  file { $::bind::config::main_config_path:
    ensure       => file,
    content      => template("${module_name}/named.conf.erb"),
    validate_cmd => '/usr/sbin/named-checkconf %',
    owner        => $::bind::config::daemon_owner,
    group        => $::bind::config::daemon_group,
    purge        => $::bind::purge_configuration,
    recurse      => $::bind::purge_configuration,
    force        => $::bind::purge_configuration,
    mode         => '0640',
    require      => [
      File[$::bind::config::options_config_path],
      Concat[$::bind::config::local_config_path]
    ]
  }

  ### Create named.conf.options configuration file.
  file { $::bind::config::options_config_path:
    ensure       => file,
    content      => template("${module_name}/named.conf.options.erb"),
    before       => File[$::bind::config::main_config_path],
    validate_cmd => '/usr/sbin/named-checkconf %',
    owner        => $::bind::config::daemon_owner,
    group        => $::bind::config::daemon_group,
    purge        => $::bind::purge_configuration,
    recurse      => $::bind::purge_configuration,
    force        => $::bind::purge_configuration,
    mode         => '0640'
  }

  ### Create named.conf.local configuration file.
  concat { $::bind::config::local_config_path:
    ensure => present,
    before => File[$::bind::config::main_config_path],
    notify => Exec['validate_named_conf_local'],
    owner  => $::bind::config::daemon_owner,
    group  => $::bind::config::daemon_group,
    mode   => '0640',
  }

  exec { 'validate_named_conf_local':
    command     => "/usr/sbin/named-checkconf '${::bind::config::local_config_path}'",
    refreshonly => true
  }

  ### Using an rndc config file and a key will create weirdness.
  if $::bind::use_rndc_config and $::bind::use_rndc_key {
    warning('Using rndc configuration file will override rndc key file!')
  }

  if $::bind::use_rndc_key {
    ### Ensure we have an rndc key available.
    bind::resource::key { 'rndc-key':
      ensure    => present,
      secret    => $::bind::rndc_key_secret,
      algorithm => 'hmac-md5'
    }

    ### Ensure a symlink exists to the rndc key we created.
    file { $::bind::config::rndc_key_path:
      ensure  => link,
      target  => "${::bind::config::keys_directory}/rndc-key.conf",
      require => Bind::Resource::Key['rndc-key']
    }
  }

  if $::bind::use_rndc_config {
    ### Ensure the rndc configuration file has been created.
    file { $::bind::config::rndc_config_path:
      ensure  => file,
      content => template("${module_name}/rndc.conf.erb"),
      owner   => $::bind::config::daemon_owner,
      group   => $::bind::config::daemon_group,
      mode    => '0600'
    }
  }

  ### Ensure we have the DNSSEC anchors available.
  file { $::bind::config::bind_keys_file:
    ensure => file,
    source => "puppet:///modules/${module_name}/bind.keys",
    owner  => $::bind::config::daemon_owner,
    group  => $::bind::config::daemon_group,
    mode   => '0644'
  }

  ### Create the root zone hints.
  bind::resource::zone { 'root':
    ensure => present,
    source => "puppet:///modules/${module_name}/db.root",
    type   => 'hint',
    origin => '.'
  }

  create_resources('bind::resource::acl',  hiera_hash('bind::acls',  {}))
  create_resources('bind::resource::key',  hiera_hash('bind::keys',  {}))
  create_resources('bind::resource::zone', hiera_hash('bind::zones', {}))
}
