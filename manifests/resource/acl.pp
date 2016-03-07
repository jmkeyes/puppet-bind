# == Resource: bind::resource::acl
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
    target  => $bind::config::local_config_path
  }
}

