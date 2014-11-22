require 'puppet/util/feature'

Puppet.features.rubygems?
Puppet.features.add(:dnsruby, :libs => 'dnsruby')
