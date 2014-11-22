# Todo

## Improve RSpec Tests.

The RSpec tests currently only check that the catalog will compile and
that there are no glaring errors in syntax, etc. This should be fixed.

## Expand on Distribution Specifics

RedHat-family distributions have a different approach to managing BIND
than Debian-family ones. This includes where configuration files exist,
what files and directories BIND owns, what permissions BIND requires
on those files and directories, and where to store and what to name
the zone databases BIND uses.

## Zone / Record Management and Synthesis

Puppet isn't the place to store a large amount of application-specific
information, like DNS zones and records. DNS contains it's own mechanisms
for ensuring consistency: DNS is a distributed database.

This module should set up a given server with the prerequisite packages
and manage configuration files to support a BIND DNS server. If Puppet
needs to enforce the presence or state of a given zone or resource
record, it should do so though a defined mechanism like zone transfers.

## Mandatory Access Control Mechanisms

This module should natively support running BIND within environments
where SELinux, AppArmor and friends are used. If you have to disable a
built-in security mechaism to run your software, you're doing it wrong.

## `chroot` Support

This module should be able to natively support chrooted BIND servers.

## Other Distributions / Operating Systems

This module should be able to configure and run BIND anywhere that both
Puppet and BIND can run. Linux distributions are only the start.
