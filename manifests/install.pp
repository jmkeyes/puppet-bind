# == Class: bind::install
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

class bind::install {
  if $caller_module_name != $module_name {
    fail('Do not include ::bind::install directly!')
  }

  validate_string($::bind::package_name)

  validate_string($::bind::package_ensure)
  validate_re($::bind::package_ensure, '^(present|latest|nstalled|[._0-9a-zA-Z:-]+)$')

  package { $::bind::package_name:
    ensure => $::bind::package_ensure
  }
}

