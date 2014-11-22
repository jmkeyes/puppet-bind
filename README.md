# Yet Another Puppet ::bind Module

[![Puppet Forge](http://img.shields.io/puppetforge/v/jmkeyes/bind.svg)](https://forge.puppetlabs.com/jmkeyes/bind)
[![Build Status](https://travis-ci.org/jmkeyes/puppet-bind.svg?branch=master)](https://travis-ci.org/jmkeyes/puppet-bind)

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

All public configuration parameters can be found in [manifests/init.pp](manifests/init.pp).

When a stable release is available, it's available parameters will be documented here.

