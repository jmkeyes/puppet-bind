# == Class: bind::firewall

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
