# Yet Another Puppet ::bind Module

#### Table of Contents

 1. [Overview](#overview)
 2. [Description](#description)
 3. [Todo](#todo)

## Overview

This is yet another Puppet module to manage the ISC BIND DNS server. It currently targets the
latest stable release of Puppet 3 and should support both RedHat and Debian family distributions.

*Beware that this module will recursively purge your distribution's default BIND configuration.*

## Description

Using this module is easy. All distribution-specific configuration is handled by Hiera.

    include ::bind

You can also use a resource-like declaration if you'd like to:

    class { '::bind': }

## Configuration

This module is built around `ripienaar/module_data` so all configuration should be stored in your
Hiera configration. You can still use parameterized classes if you'd like but Hiera will make the
task much easier. 

Hiera will handle all distribution-specific configuration, but if you have a custom distribution
that you would like to support, you can override the keys within `data/osfamily/%{::osfamily}.yaml`
in your local Hiera configuration. All other configuration keys are located in `data/common.yaml`.

## Todo

 * Improve RSpec tests; it currently only checks for catalog compilation failures.
 * Expand on user/group permissions; some distributions do things differently.
 * Improve zone/record synthesis; it should support comments as well.
 * Move all built-in defined resources into Hiera.
 * Support SELinux on distributions that use it.
 * Properly support chrooted BIND servers.
 * Extend support to other distributions.

