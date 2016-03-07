# == Class: bind::firewall
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

class bind::firewall {
  if ! defined('firewall') {
    fail('The puppetlabs/firewall module does not appear to be installed!')
  } else {
    firewall {
      '100 Allow all inbound DNS queries over UDP':
        action => 'accept',
        chain  => 'INPUT',
        proto  => 'udp',
        port   => '53';
      '100 Allow all inbound DNS queries over TCP':
        action => 'accept',
        chain  => 'INPUT',
        proto  => 'tcp',
        port   => '53';
    }
  }
}
