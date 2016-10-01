# Cassandra
[![Puppet Forge](http://img.shields.io/puppetforge/v/locp/cassandra.svg)](https://forge.puppetlabs.com/locp/cassandra)
[![Github Tag](https://img.shields.io/github/tag/locp/cassandra.svg)](https://github.com/locp/cassandra)
[![Build Status](https://travis-ci.org/locp/cassandra.png?branch=master)](https://travis-ci.org/locp/cassandra)
[![Coverage Status](https://coveralls.io/repos/locp/cassandra/badge.svg?branch=master&service=github)](https://coveralls.io/github/locp/cassandra?branch=master)
[![Join the chat at https://gitter.im/locp/cassandra](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/locp/cassandra?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

#### Table of Contents

1. [Overview](#overview)
1. [Setup - The basics of getting started with Cassandra](#setup)
    * [What Cassandra affects](#what-cassandra-affects)
    * [Upgrading](#upgrading)
    * [Beginning with Cassandra](#beginning-with-cassandra)
1. [Usage - Configuration options and additional functionality](#usage)
    * [Setup a keyspace and users](#setup-a-keyspace-and-users)
    * [Create a Cluster in a Single Data Center](#create-a-cluster-in-a-single-data-center)
    * [Create a Cluster in Multiple Data Centers](#create-a-cluster-in-multiple-data-centers)
    * [DataStax Enterprise](#datastax-enterprise)
1. [Reference](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Contributers](#contributers)

## Overview

A Puppet module to install and manage Cassandra, DataStax Agent & OpsCenter

## Setup

### What Cassandra affects

#### What the Cassandra class affects

* Installs the Cassandra package (default **cassandra22** on Red Hat and
  **cassandra** on Debian).
* Configures settings in *${config_path}/cassandra.yaml*.
* On CentOS 7 if the `init` service provider is used, then cassandra
  is added as a system service.
* Optionally ensures that the Cassandra service is enabled and running.
* On Debian systems:
  * Optionally replace ```/etc/init.d/cassandra``` with a workaround for
  [CASSANDRA-9822](https://issues.apache.org/jira/browse/CASSANDRA-9822).

#### What the cassandra::datastax_agent class affects

* Optionally installs the DataStax agent.
* Optionally sets JAVA_HOME in **/etc/default/datastax-agent**.

#### What the cassandra::datastax_repo class affects

* Optionally configures a Yum repository to install the Cassandra packages
  from (on Red Hat).
* Optionally configures an Apt repository to install the Cassandra packages
  from (on Debian).

#### What the cassandra::firewall_ports class affects

* Optionally configures the firewall for the Cassandra related network
  ports.

#### What the cassandra::java class affects

* Optionally installs a JRE/JDK package (e.g. java-1.7.0-openjdk) and the
  Java Native Access (JNA).

#### What the cassandra::optutils class affects

* Optionally installs the Cassandra support tools (e.g. cassandra22-tools).

### Upgrading

We follow [SemVer Versioning](http://semver.org/) and an update of the major
release (i.e. from 1.*Y*.*Z* to 2.*Y*.*Z*) will indicate a significant change
to the API which will most probably require a change to your manifest.

#### Changes in 2.0.0

This is a major change to the API and you will more than likely need to
change your manifest to accomodate these changes.

The `service_ensure` attribute of the cassandra class now defaults to
*undef*, users who do want to manage service status in Puppet can still set
it to true.  If leaving the value at the default and setting
`service_refresh` and `service_enable` to false will mean that the
user and not Puppet running will control the running state of
Cassandra.  This currently works OK on the Red Hat family, but
has issues on Debian due to
[CASSANDRA-2356](https://issues.apache.org/jira/browse/CASSANDRA-2356)
during an initial install or package upgrade.

All the functionality relating to OpsCenter has been divested to the
[locp/opscenter](https://forge.puppet.com/locp/opscenter) module on
Puppet Forge.

It should also be noted that the module no longer creates directories for
the `data`, `commitlog`, `saved_caches` and for Cassandra 3 the `hints`
directory.  These resources will now need to be defined in your
manifest/profile.

For a list of features that have been deprecated in this release, please see
https://github.com/locp/cassandra/wiki/Deprecations

For details on migrating from the version 1.X.X attributes to the `settings`
hash, see
https://github.com/locp/cassandra/wiki/Version-1.X.Y-Template-Defaults-Shown-As-2.X.Y-Hash

Please also see the notes for 2.0.0 in the
[CHANGELOG](https://forge.puppet.com/locp/cassandra/changelog).

#### Changes in 1.19.0

The hints_directory documentation will cause a change in the cassandra.yaml
file regardless of the value you set it to.  If you do not wish this to
result in a refesh of the Cassandra service, please set service_refresh to
false.

#### Changes in 1.9.2

Now that Cassandra 3 is available from the DataStax repositories, there is
a problem (especially on Debian) with the operating system package manager
attempting to install Cassandra 3.  This can be mitigated against using
something similar to the code in this modules acceptance test.  Please note
that the default Cassandra package name has now been changed from 'dsc'.  See
the documentation for cassandra::package_name below for details.

```puppet
 if $::osfamily == 'RedHat' {
   $version = '2.2.4-1'
 } else {
   $version = '2.2.4'
 }

 class { 'cassandra':
   package_ensure => $version,
 }
```

#### Changes in 1.8.0

A somewhat embarrassing correction to the spelling of the
cassandra::fail_on_non_suppoted_os to cassandra::fail_on_non_supported_os.

#### Issues when Upgrading to 1.4.0

Unfortunately both releases 1.3.7 and 1.4.0 have subsequently been found to
call a refresh service even when no changes had been made to the underlying
configuration.  In release 1.8.0 (somewhat belatedly) the service_refresh
flag has been introduced to mitigate against similar problems.

#### Issues When Upgrading to 1.3.7

* Please see the notes for 1.4.0.

#### Changes in 1.0.0

* cassandra::cassandra_package_ensure has been renamed to
  cassandra::package_ensure.
* cassandra::cassandra_package_name has been renamed to
  cassandra::package_name.

#### Changes in 0.4.0

There is now a cassandra::datastax_agent class, therefore:

* cassandra::datastax_agent_package_ensure has now been replaced with
  cassandra::datastax_agent::package_ensure.
* cassandra::datastax_agent_service_enable has now been replaced with
  cassandra::datastax_agent::service_enable.
* cassandra::datastax_agent_service_ensure has now been replaced with
  cassandra::datastax_agent::service_ensure.
* cassandra::datastax_agent_package_name has now been replaced with
  cassandra::datastax_agent::package_name.
* cassandra::datastax_agent_service_name has now been replaced with
  cassandra::datastax_agent::service_name.

Likewise now there is a new class for handling the installation of Java:

* cassandra::java_package_ensure has now been replaced with
  cassandra::java::ensure.
* cassandra::java_package_name has now been replaced with
  cassandra::java::package_name.

Also there is now a class for installing the optional utilities:

* cassandra::cassandra_opt_package_ensure has now been replaced with
  cassandra::optutils:ensure.
* cassandra::cassandra_opt_package_name has now been replaced with
  cassandra::optutils:package_name.

#### Changes in 0.3.0

* cassandra_opt_package_ensure changed from 'present' to undef.

* The manage_service option has been replaced with service_enable and
  service_ensure.

### Beginning with Cassandra

```puppet
# Cassandra pre-requisites
include cassandra::datastax_repo
include cassandra::java

# Create a cluster called MyCassandraCluster which uses the
# GossipingPropertyFileSnitch.  In this very basic example
# the node itself becomes a seed for the cluster.
class { 'cassandra':
  authenticator   => 'PasswordAuthenticator',
  cluster_name    => 'MyCassandraCluster',
  endpoint_snitch => 'GossipingPropertyFileSnitch',
  listen_address  => $::ipaddress,
  seeds           => $::ipaddress,
  require         => Class['cassandra::datastax_repo', 'cassandra::java'],
}

class { 'cassandra':
  settings => {
    'authenticator'               => 'PasswordAuthenticator',
    'cluster_name'                => 'MyCassandraCluster',
    'commitlog_directory'         => '/var/lib/cassandra/commitlog',
    'commitlog_sync'              => 'periodic',
    'commitlog_sync_period_in_ms' => 10000,
    'data_file_directories'       => ['/var/lib/cassandra/data'],
    'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
    'listen_address'              => $::ipaddress,
    'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
    'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
    'seed_provider'               => [
      {
        'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
        'parameters' => [
          {
            'seeds' => $::ipaddress,
          },
        ],
      },
    ],
    'start_native_transport'      => true,
  },
  require  => Class['cassandra::datastax_repo', 'cassandra::java'],
}
```

## Usage

### Setup a keyspace and users

We assume that authentication has been enabled for the cassandra
cluster and we are connecting with the default user name and password
('cassandra/cassandra').

In this example, we create a keyspace (mykeyspace) with a table called
'users' and an index called 'users_lname_idx'.

We also add three users (to Cassandra, not the mykeyspace.users
table) called spillman, akers and boone while ensuring that a user
called lucan is absent.

```puppet
class { 'cassandra':
  ...
}

class { 'cassandra::schema':
  cqlsh_password => 'cassandra',
  cqlsh_user     => 'cassandra',
  cqlsh_host     => $::ipaddress,
  indexes        => {
    'users_lname_idx' => {
      table    => 'users',
      keys     => 'lname',
      keyspace => 'mykeyspace',
    },
  },
  keyspaces      => {
    'mykeyspace' => {
      durable_writes  => false,
      replication_map => {
        keyspace_class     => 'SimpleStrategy',
        replication_factor => 1,
      },
    }
  },
  tables         => {
    'users' => {
      columns  => {
        user_id       => 'int',
        fname         => 'text',
        lname         => 'text',
        'PRIMARY KEY' => '(user_id)',
      },
      keyspace => 'mykeyspace',
    },
  },
  users          => {
    'spillman' => {
      password => 'Niner27',
    },
    'akers'    => {
      password  => 'Niner2',
      superuser => true,
    },
    'boone'    => {
      password => 'Niner75',
    },
    'lucan'    => {
      'ensure' => absent
    },
  },
}
```

### Create a Cluster in a Single Data Center

In the DataStax documentation _Initializing a multiple node cluster (single
data center)_
<http://docs.datastax.com/en/cassandra/2.2/cassandra/initialize/initSingleDS.html>
there is a basic example of a six node cluster with two seeds to be created in
a single data center spanning two racks.  The nodes in the cluster are:

**Node Name**  | **IP Address** |
---------------|----------------|
node0 (seed 1) | 110.82.155.0   |
node1          | 110.82.155.1   |
node2          | 110.82.155.2   |
node3 (seed 2) | 110.82.156.3   |
node4          | 110.82.156.4   |
node5          | 110.82.156.5   |

Each node is configured to use the GossipingPropertyFileSnitch and 256 virtual
nodes (vnodes).  The name of the cluster is _MyCassandraCluster_.  Also,
while building the initial cluster, we are setting the auto_bootstrap
to false.

In this initial example, we are going to expand the example by:

* Ensuring that the software is installed via the DataStax Community
  repository by including `cassandra::datastax_repo`.  This needs to be
  executed before the Cassandra package is installed.
* That a suitable Java Runtime environment (JRE) is installed with Java Native
  Access (JNA) by including `cassandra::java`.  This need to be executed
  before the Cassandra service is started.

```puppet
node /^node\d+$/ {
  class { 'cassandra::datastax_repo':
    before => Class['cassandra']
  }

  class { 'cassandra::java':
    before => Class['cassandra']
  }

  class { 'cassandra':
    cluster_name     => 'MyCassandraCluster',
    endpoint_snitch  => 'GossipingPropertyFileSnitch',
    listen_interface => "eth1",
    num_tokens       => 256,
    seeds            => '110.82.155.0,110.82.156.3',
    auto_bootstrap   => false
  }
}
```

The default value for the num_tokens is already 256, but it is
included in the example for clarity.  Do not forget to either
set auto_bootstrap to true or not set the attribute at all
after initializing the cluster.

### Create a Cluster in Multiple Data Centers

To continue with the examples provided by DataStax, we look at the example
for a cluster across multiple data centers
<http://docs.datastax.com/en/cassandra/2.2/cassandra/initialize/initMultipleDS.html>.

**Node Name**  | **IP Address** | **Data Center** | **Rack** |
---------------|----------------|-----------------|----------|
node0 (seed 1) | 10.168.66.41   | DC1             | RAC1     |
node1          | 10.176.43.66   | DC1             | RAC1     |
node2          | 10.168.247.41  | DC1             | RAC1     |
node3 (seed 2) | 10.176.170.59  | DC2             | RAC1     |
node4          | 10.169.61.170  | DC2             | RAC1     |
node5          | 10.169.30.138  | DC2             | RAC1     |

For the sake of simplicity, we will confine this example to the nodes:

```puppet
node /^node[012]$/ {
  class { 'cassandra':
    cluster_name    => 'MyCassandraCluster',
    endpoint_snitch => 'GossipingPropertyFileSnitch',
    listen_address  => "${::ipaddress}",
    num_tokens      => 256,
    seeds           => '10.168.66.41,10.176.170.59',
    dc              => 'DC1',
    auto_bootstrap  => false
  }
}

node /^node[345]$/ {
  class { 'cassandra':
    cluster_name    => 'MyCassandraCluster',
    endpoint_snitch => 'GossipingPropertyFileSnitch',
    listen_address  => "${::ipaddress}",
    num_tokens      => 256,
    seeds           => '10.168.66.41,10.176.170.59',
    dc              => 'DC2',
    auto_bootstrap  => false
  }
}
```

We don't need to specify the rack name (with the rack attribute) as RAC1 is
the default value.  Again, do not forget to either set auto_bootstrap to
true or not set the attribute at all after initializing the cluster.

## Reference

### Public Classes

* [cassandra](#class-cassandra)
* [cassandra::datastax_agent](#class-cassandradatastax_agent)
* [cassandra::datastax_repo](#class-cassandradatastax_repo)
* [cassandra::firewall_ports](#class-cassandrafirewall_ports)
* [cassandra::java](#class-cassandrajava)
* [cassandra::optutils](#class-cassandraoptutils)
* [cassandra::schema](#class-cassandraschema)

### Public Defined Types

* [cassandra::file](#defined-type-cassandrafile)
* [cassandra::schema::cql_type](#defined-type-cassandraschemacql_type)
* [cassandra::schema::index](#defined-type-cassandraschemaindex)
* [cassandra::schema::keyspace](#defined-type-cassandraschemakeyspace)
* [cassandra::schema::table](#defined-type-cassandraschematable)
* [cassandra::schema::user](#defined-type-cassandraschemauser)

### Private Defined Types

* [cassandra::private::deprecation_warning](#defined-type-cassandraprivatedeprecation_warning)
* [cassandra::private::firewall_ports::rule](#defined-type-cassandraprivatefirewall_portsrule)

### Attributes

A class for installing the Cassandra package and manipulate settings in the
configuration file.

#### Class: cassandra

##### `cassandra_2356_sleep_seconds`
This will provide a workaround for
[CASSANDRA-2356](https://issues.apache.org/jira/browse/CASSANDRA-2356) by
sleeping for the specifed number of seconds after an event involving the
Cassandra package.

This option is silently ignored on the Red Hat family of operating systems as
this bug only affects Debian systems.
Default value 5

##### `cassandra_9822`
If set to true, this will apply a patch to the init file for the Cassandra
service as a workaround for
[CASSANDRA-9822](https://issues.apache.org/jira/browse/CASSANDRA-9822).  This
option is silently ignored on the Red Hat family of operating systems as
this bug only affects Debian systems.
Default value 'false'

##### `cassandra_yaml_tmpl`
The path to the Puppet template for the Cassandra configuration file.  This
allows the user to supply their own customized template.
Default value 'cassandra/cassandra.yaml.erb'

##### `config_file_mode`
The permissions mode of the cassandra configuration file.
Default value '0644'

##### `config_path`
The path to the cassandra configuration file.
Default value **/etc/cassandra/default.conf** on Red Hat
or **/etc/cassandra** on Debian.

##### `dc`
Sets the value for dc in *config_path*/*snitch_properties_file* see
http://docs.datastax.com/en/cassandra/2.1/cassandra/architecture/architectureSnitchesAbout_c.html
for more details.
Default value 'DC1'

##### `dc_suffix`
Sets the value for dc_suffix in *config_path*/*snitch_properties_file* see
http://docs.datastax.com/en/cassandra/2.1/cassandra/architecture/architectureSnitchesAbout_c.html
for more details.  If the value is *undef* then change will be made to the
snitch properties file for this setting.
Default value *undef*

##### `fail_on_non_supported_os`
A flag that dictates if the module should fail if it is not RedHat or Debian.
If you set this option to false then you must also at least set the
`config_path` attribute as well.
Default value 'true'

##### `package_ensure`
The status of the package specified in **package_name**.  Can be
*present*, *latest* or a specific version number.
Default value 'present'

##### `package_name`
The name of the Cassandra package which must be available from a repository.
Default value **cassandra22** on the Red Hat family of operating systems
or **cassandra** on Debian.

##### `prefer_local`
Sets the value for prefer_local in *config_path*/*snitch_properties_file* see
http://docs.datastax.com/en/cassandra/2.1/cassandra/architecture/architectureSnitchesAbout_c.html
for more details.  Valid values are true, false or *undef*.  If the value is
*undef* then change will be made to the snitch properties file for this
setting.
Default value *undef*

##### `rack`
Sets the value for rack in *config_path*/*snitch_properties_file* see
http://docs.datastax.com/en/cassandra/2.1/cassandra/architecture/architectureSnitchesAbout_c.html
for more details.
Default value 'RAC1'

##### `rackdc_tmpl`
The template for creating the snitch properties file.
Default value 'cassandra/cassandra-rackdc.properties.erb'

##### `service_enable`
Enable the Cassandra service to start at boot time.  Valid values are true
or false.
Default value 'true'

##### `service_ensure`
Ensure the Cassandra service is running.  Valid values are running or stopped.
Default value *undef*

##### `service_name`
The name of the service that runs the Cassandra software.
Default value 'cassandra'

##### `service_provider`
The name of the provider that runs the service.  If left as *undef* then the OS family specific default will
be used, otherwise the specified value will be used instead.
Default value *undef*

##### `service_refresh`
If set to true, changes to the Cassandra config file or the data directories
will ensure that Cassandra service is refreshed after the changes.  Setting
this flag to false will disable this behaviour, therefore allowing the changes
to be made but allow the user to control when the service is restarted.
Default value true

##### `settings`

A hash that is passed to `to_yaml` which dumps the results to the Cassandra
configuring file.  The minimum required settings for Cassandra 2.X
are as follows:

```puppet
{
  'authenticator'               => 'PasswordAuthenticator',
  'cluster_name'                => 'MyCassandraCluster',
  'commitlog_directory'         => '/var/lib/cassandra/commitlog',
  'commitlog_sync'              => 'periodic',
  'commitlog_sync_period_in_ms' => 10000,
  'data_file_directories'       => ['/var/lib/cassandra/data'],
  'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
  'listen_address'              => $::ipaddress,
  'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
  'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
  'seed_provider'               => [
    {
      'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
      'parameters' => [
        {
          'seeds' => $::ipaddress,
        },
      ],
    },
  ],
  'start_native_transport'      => true,
}
```

For Cassandra 3.X you will also need to specify the `hints_directory`
attribute.
Default value {}

##### `snitch_properties_file`
The name of the snitch properties file.  The full path name would be
*config_path*/*snitch_properties_file*.
Default value 'cassandra-rackdc.properties'

#### Class: cassandra::datastax_agent

A class for installing the DataStax Agent and to point it at an OpsCenter
instance.

In this example set agent_alias to foobar, stomp_interface to localhost and
ensure that async_pool_size is absent from the file:

```puppet
class { 'cassandra::datastax_agent':
  settings => {
    'agent_alias'     => {
      'setting' => 'agent_alias',
      'value'   => 'foobar',
    },
    'stomp_interface' => {
      'setting' => 'stomp_interface',
      'value'   => 'localhost',
    },
    'async_pool_size' => {
      'ensure' => absent,
    },
  },
}
```

##### `address_config_file`
The full path to the address config file.
Default value '/var/lib/datastax-agent/conf/address.yaml'

##### `defaults_file`
The full path name to the file where `java_home` is set.
Default value '/etc/default/datastax-agent'

##### `java_home`
If the value of this variable is left as *undef*, no action is taken.
Otherwise the value is set as JAVA_HOME in `defaults_file`.
Default value *undef*

##### `package_ensure`
Is passed to the package reference.  Valid values are **present** or a version
number.
Default value 'present'

##### `package_name`
Is passed to the package reference.
Default value 'datastax-agent'

##### `service_ensure`
Is passed to the service reference.
Default value 'running'

##### `service_enable`
Is passed to the service reference.
Default value 'true'

##### `service_name`
Is passed to the service reference.
Default value 'datastax-agent'

##### `service_provider`
The name of the provider that runs the service.  If left as *undef* then the OS family specific default will
be used, otherwise the specified value will be used instead.
Default value *undef*

##### `settings`
A hash that is passed to
[create_ini_settings](https://github.com/puppetlabs/puppetlabs-inifile#function-create_ini_settings)
with the following additional defaults:

```puppet
{
  path              => $address_config_file,
  key_val_separator => ': ',
  require           => Package[$package_name],
  notify            => Service['datastax-agent'],
}
```

Default value {}

#### Class: cassandra::datastax_repo

An optional class that will allow a suitable repository to be configured
from which packages for DataStax Community can be downloaded.  Changing
the defaults will allow any Debian Apt or Red Hat Yum repository to be
configured.

##### `descr`
On the Red Hat family, this is passed as the `descr` attribute to a
`yumrepo` resource.  On the Debian family, it is passed as the `comment`
attribute to an `apt::source` resource.
Default value 'DataStax Repo for Apache Cassandra'

##### `key_id`
On the Debian family, this is passed as the `id` attribute to an `apt::key`
resource.  On the Red Hat family, it is ignored.
Default value '7E41C00F85BFC1706C4FFFB3350200F2B999A372'

##### `key_url`
On the Debian family, this is passed as the `source` attribute to an
`apt::key` resource.  On the Red Hat family, it is ignored.
Default value 'http://debian.datastax.com/debian/repo_key'

##### `pkg_url`
If left as the default, this will set the `baseurl` to
'http://rpm.datastax.com/community' on a `yumrepo` resource
on the Red Hat family.  On the Debian family, leaving this as the default
will set the `location` attribute on an `apt::source` to
'http://debian.datastax.com/community'.  Default value *undef*

##### `release`
On the Debian family, this is passed as the `release` attribute to an
`apt::source` resource.  On the Red Hat family, it is ignored.
Default value 'stable'

#### Defined Type: cassandra::file

A definition for altering files relative to the configuration directory.  For
example set the MAX_HEAP_SIZE and and HEAP_NEWSIZE for the JVM depending on
the memory and number of processors on the node:

```puppet
if $::memorysize_mb < 24576.0 {
  $max_heap_size_in_mb = floor($::memorysize_mb / 2)
} elsif $::memorysize_mb < 8192.0 {
  $max_heap_size_in_mb = floor($::memorysize_mb / 4)
} else {
  $max_heap_size_in_mb = 8192
}

$heap_new_size = $::processorcount * 100

cassandra::file { "Set Java/Cassandra max heap size to ${max_heap_size_in_mb}.":
  file       => 'cassandra-env.sh',
  file_lines => {
    'MAX_HEAP_SIZE' => {
      line  => "MAX_HEAP_SIZE='${max_heap_size_in_mb}M'",
      match => '^#?MAX_HEAP_SIZE=.*',
    },
  }
}

cassandra::file { "Set Java/Cassandra heap new size to ${heap_new_size}.":
  file       => 'cassandra-env.sh',
  file_lines => {
    'HEAP_NEWSIZE'  => {
      line  => "HEAP_NEWSIZE='${heap_new_size}M'",
      match => '^#?HEAP_NEWSIZE=.*',
    }
  }
}

$tmpdir = '/var/lib/cassandra/tmp'

file { $tmpdir:
  ensure => directory,
  owner  => 'cassandra',
  group  => 'cassandra',
}

cassandra::file { 'Set java.io.tmpdir':
  file       => 'jvm.options',
  file_lines => {
    'java.io.tmpdir' => {
      line => "-Djava.io.tmpdir=${tmpdir}",
    },
  },
  require    => File[$tmpdir],
}
```

##### `file`
The name of the file relative to the `config_path`.  This defaults to the
title of the definition.

##### `config_path`
The path to the configuration directory.  On the RedHat family this will
default to `/etc/cassandra/default.conf` on Debian, the
default is `/etc/cassandra`.

##### `file_lines`
If set, then the [create_resources](https://docs.puppet.com/puppet/latest/reference/function.html#createresources)
will be used to create an array of
[file_line](https://forge.puppet.com/puppetlabs/stdlib#file_line) resources
where the path attribute is set to `${config_path}/${file}`
Default *undef*

##### `service_refresh`
If the Cassandra service is to be notified if the environment file is changed.
Set to false if this is not wanted.
Default value true.

#### Class: cassandra::firewall_ports

An optional class to configure incoming network ports on the host that are
relevant to the Cassandra installation.  If firewalls are being managed
already, simply do not include this module in your manifest.

IMPORTANT: The full list of which ports should be configured is assessed at
evaluation time of the configuration. Therefore if one is to use this class,
it must be the final cassandra class included in the manifest.

##### `client_ports`
Only has any effect if the `cassandra` class is defined on the node.

Allow these TCP ports to be opened for traffic
coming from the client subnets.
Default value '[9042, 9160]'

##### `client_subnets`
Only has any effect if the `cassandra` class is defined on the node.

An array of the list of subnets that are to allowed connection to
cassandra::native_transport_port and cassandra::rpc_port.
Default value '['0.0.0.0/0']'

##### `inter_node_ports`
Only has any effect if the `cassandra` class is defined on the node.

Allow these TCP ports to be opened for traffic
between the Cassandra nodes.
Default value '[7000, 7001, 7199]'

##### `inter_node_ports`
Allow these TCP ports to be opened for traffic
coming from OpsCenter subnets.
Default value '[7000, 7001, 7199]'

##### `inter_node_subnets`
Only has any effect if the `cassandra` class is defined on the node.

An array of the list of subnets that are to allowed connection to
cassandra::storage_port, cassandra::ssl_storage_port and port 7199
for cassandra JMX monitoring.
Default value '['0.0.0.0/0']'

##### `public_ports`
Allow these TCP ports to be opened for traffic
coming from public subnets the port specified in `$ssh_port` will be
appended to this list.
Default value '[8888]'

##### `public_subnets`
An array of the list of subnets that are to allowed connection to
cassandra::firewall_ports::ssh_port.
Default value '['0.0.0.0/0']'

##### `ssh_port`
Which port does SSH operate on.
Default value '22'

##### `opscenter_ports`
Only has any effect if the `cassandra::datastax_agent` is defined.

Allow these TCP ports to be opened for traffic coming to or from OpsCenter
appended to this list.
Default value [9042, 9160, 61620, 61621]

##### `opscenter_subnets`
A list of subnets that are to be allowed connection to
port 61621 for nodes built with cassandra::datastax_agent.
Default value '['0.0.0.0/0']'

#### Class: cassandra::java

A class to install an appropriate Java package.

##### `aptkey`
If supplied, this should be a hash of *apt::key* resources that will be passed
to the create_resources function.  This is ignored on non-Debian systems.
Default value *undef*

##### `aptsource`
If supplied, this should be a hash of *apt::source* resources that will be
passed to the create_resources function.  This is ignored on non-Red Hat
systems.  Default value *undef*

##### `jna_ensure`
Is passed to the package reference for the JNA package.  Valid values are
**present** or a version number.
Default value 'present'

##### `jna_package_name`
The name of the JNA package.
Default value jna or libjna-java will be installed on a Red Hat family or
Debian system respectively.

##### `package_ensure`
Is passed to the package reference for the JRE/JDK package.  Valid values are
**present** or a version number.
Default value 'present'

##### `package_name`
The name of the Java package to be installed.
Default value java-1.8.0-openjdk-headless on Red Hat openjdk-7-jre-headless
on Debian.

##### `yumrepo`
If supplied, this should be a hash of *yumrepo* resources that will be passed
to the create_resources function.  This is ignored on non-Red Hat systems.
Default value *undef*

#### Class: cassandra::optutils

A class to install the optional Cassandra tools package.

##### `package_ensure`
The status of the package specified in **package_name**.  Can be
*present*, *latest* or a specific version number.
Default value 'present'

##### `package_name`
The name of the optional utilities package to be installed.  This
defaults to `cassandra22-tools` or `cassandra-tools`
on a Red Hat family or Debian system respectively.

#### Class: cassandra::schema

A class to maintain the database schema.  Please note that cqlsh expects
Python 2.7 to be installed.  This may be a problem of older distributions
(CentOS 6 for example).

##### `connection_tries`
How many times do try to connect to Cassandra.  See also `connection_try_sleep`.

Default value 6

##### `connection_try_sleep`
How much time to allow between the number of tries specified in
`connection_tries`.

Default value 30

##### `cql_types`
Creates new `cassandra::schema::cql_type` resources. Valid options: a hash to
be passed to the `create_resources` function. Default: {}.

##### `cqlsh_additional_options`
Any additional options to be passed to the **cqlsh** command.

Default value ''

##### `cqlsh_client_config`
Set this to a file name (e.g. **/root/.puppetcqlshrc**) that will then be used
to contain the credentials for connecting to Cassandra.  This is a more
secure option than having the credentials appearing on the command line.  This
option is only available in Cassandra 2.1.

Default value *undef*

##### `cqlsh_client_tmpl`
The location of the template for configuring the credentials for the cqlsh
client.  This is ignored unless `cqlsh_client_config` is set.

Default value 'cassandra/cqlshrc.erb'

##### `cqlsh_command`
The full path to the **cqlsh** command.

Default value '/usr/bin/cqlsh'

##### `cqlsh_host`
The host for the **cqlsh** command to connect to.  See also `cqlsh_port`.

Default value 'localhost'

##### `cqlsh_password`
If credentials are require for connecting, specify the password here.
See also `cqlsh_user`.  See also `cqlsh_client_config`.

Default value *undef*

##### `cqlsh_port`
The host for the **cqlsh** command to connect to.  See also `cqlsh_host`.
See also `cqlsh_host`.

Default value 9042

##### `cqlsh_user`
If credentials are require for connecting, specify the password here.
See also `cqlsh_password`.  See also `cqlsh_client_config`.

Default value 'cassandra'

##### `indexes`
Creates new `cassandra::schema::indexes` resources. Valid options: a hash to
be passed to the `create_resources` function. Default: {}.

##### `keyspaces`
Creates new `cassandra::schema::keyspace` resources. Valid options: a hash to
be passed to the `create_resources` function. Default: {}.

##### `tables`
Creates new `cassandra::schema::table` resources. Valid options: a hash to
be passed to the `create_resources` function. Default: {}.

##### `users`
Creates new `cassandra::schema::user` resources. Valid options: a hash to
be passed to the `create_resources` function. Default: {}.

#### Defined Type cassandra::schema::cql_type

Create or drop user defined data types within the schema.  Please see the
[Begining with Cassandra](#beginning-with-cassandra) section of this document.

##### `keyspace`
The name of the keyspace that the data type is to be associated with.

##### `ensure`
Valid values can be **present** to ensure a data type is created, or
**absent** to ensure it is dropped.

##### `fields`
A hash of the fields that will be components for the data type.  See
the example earlier in this document for the layout of the hash.

##### `cql_type_name`
The name of the CQL type to be created.  Defaults to the title of the
resource.

#### Defined Type cassandra::schema::index

Create or drop indexes within the schema.  Please see the
[Begining with Cassandra](#beginning-with-cassandra) section of this document.

##### `ensure`
Valid values can be **present** to ensure an index is created, or
**absent** to ensure it is dropped.

##### `class_name`
The name of the class to be associated with an index when creating
a custom index.

Default value *undef*

##### `index`
The name of the index.  Defaults to the name of the resource.  Set to
*undef* if the index is not to have a name.

##### `keys`
The columns that the index is being created on.

Default value *undef*

##### `keyspace`
The name of the keyspace that the index is to be associated with.

##### `options`
Any options to be added to the index.

Default value *undef*

##### `table`
The name of the table that the index is to be associated with.

#### Defined Type cassandra::schema::keyspace

Create or drop keyspaces within the schema.  Please see the example code in the
[Begining with Cassandra](#beginning-with-cassandra) section of this document.

##### `ensure`
Valid values can be **present** to ensure a keyspace is created, or
**absent** to ensure it is dropped.

##### `durable_writes`
When set to false, data written to the keyspace bypasses the commit log. Be
careful using this option because you risk losing data. Set this attribute to
false on a keyspace using the SimpleStrategy. Default value true.

##### `keyspace_name`
The name of the keyspace to be created. Defaults to the name of the resource.

##### `replication_map`
Needed if the keyspace is to be present.  Optional if it is to be absent.
Can be something like the following:

```puppet
$network_topology_strategy = {
  keyspace_class => 'NetworkTopologyStrategy',
  dc1            => 3,
  dc2            => 2
}
```

#### Defined Type cassandra::schema::table

Create or drop tables within the schema.  Please see the example code in the
[Begining with Cassandra](#beginning-with-cassandra) section of this document.

##### `keyspace`
The name of the keyspace.  This value is taken from the title given to the
`cassandra::schema::keyspace` resource.

##### `columns`
A hash of the columns to be placed in the table.  Optional if the table is
to be absent.

Default value {}

##### `ensure`
Valid values can be **present** to ensure a keyspace is created, or
**absent** to ensure it is dropped.

Default value **present**

##### `options`
Options to be added to the table creation.

Default value []

##### `table`
The name of the table.  Defaults to the name of the resource.

#### Defined Type cassandra::schema::user

Create or drop users.  Please see the example code in the
[Begining with Cassandra](#beginning-with-cassandra) section of this document.
To use this class, a suitable `authenticator` (e.g. PasswordAuthenticator)
must be set in the Cassandra class.

##### `ensure`
Valid values can be **present** to ensure a user is created, or **absent** to
remove the user if it exists.  Default value true.

##### `password`
A password for the user.  Default value *undef*.

##### `superuser`
If the user is to be a super-user on the system.  Default value false.

##### `user_name`
The name of the user.  Defaults to the title of the resource.

#### Defined Type cassandra::private::deprecation_warning

A defined type to handle deprecation messages to the user.
This is not intended to be used by a user but is documented here for
completeness.

##### `item_number`
A unique reference number for the specific deprecation.

#### Defined Type cassandra::private::firewall_ports::rule

A defined type to be used as a macro for setting host based firewall
rules.  This is not intended to be used by a user (who should use the
API provided by cassandra::firewall_ports instead) but is documented
here for completeness.

##### `title`
A text field that contains the protocol name and CIDR address of a subnet.

##### `port`
The number(s) of the port(s) to be opened.

## Limitations

When using a Ruby version before 1.9.0, the contents of the Cassandra
configuration file may change order of elementsdue to a problem with
to_yaml in earlier versions of Ruby.

When creating key spaces, indexes, cql_types and users the settings will only
be used to create a new resource if it does not currently exist.  If a change
is made to the Puppet manifest but the resource already exits, this change
will not be reflected.

## Contributers

Contributions will be gratefully accepted.  Please go to the project page,
fork the project, make your changes locally and then raise a pull request.
Details on how to do this are available at
https://guides.github.com/activities/contributing-to-open-source.

Please also see the
[CONTRIBUTING.md](https://github.com/locp/cassandra/blob/master/CONTRIBUTING.md)
page for project specific requirements.

### Additional Contributers

**Release**  | **PR/Issue**                                        | **Contributer**
-------------|-----------------------------------------------------|----------------------------------------------------
2.0.0        | [#266](https://github.com/locp/cassandra/issues/266)| [@stanleyz](https://github.com/stanleyz)
1.25.2       | [#269](https://github.com/locp/cassandra/issues/269)| [@ahharu](https://github.com/ahharu)
1.25.1       | [#264](https://github.com/locp/cassandra/issues/264)| [@pampelix](https://github.com/pampelix)
1.25.0       | [#261](https://github.com/locp/cassandra/pull/261)  | [@tibers](https://github.com/tibers)
1.24.0       | [#247](https://github.com/locp/cassandra/pull/247)  | [@ericy-jana](https://github.com/ericy-jana)
1.24.0       | [#246](https://github.com/locp/cassandra/pull/246)  | [@ericy-jana](https://github.com/ericy-jana)
1.24.0       | [#245](https://github.com/locp/cassandra/issues/245)| [@ericy-jana](https://github.com/ericy-jana)
1.23.0       | [#235](https://github.com/locp/cassandra/pull/235)  | [@tibers](https://github.com/tibers)
1.22.1       | [#233](https://github.com/locp/cassandra/pull/233)  | [@tibers](https://github.com/tibers)
1.22.1       | [#232](https://github.com/locp/cassandra/issues/232)| [@tibers](https://github.com/tibers)
1.21.0       | [#226](https://github.com/locp/cassandra/pull/226)  | [@tibers](https://github.com/tibers)
1.20.0       | [#217](https://github.com/locp/cassandra/issues/217)| [@samyray](https://github.com/samyray)
1.19.0       | [#215](https://github.com/locp/cassandra/pull/215)  | [@tibers](https://github.com/tibers)
1.18.0       | [#203](https://github.com/locp/cassandra/pull/203)  | [@Mike-Petersen](https://github.com/Mike-Petersen)
1.15.0       | [#189](https://github.com/locp/cassandra/pull/189)  | [@tibers](https://github.com/tibers)
1.14.0       | [#171](https://github.com/locp/cassandra/pull/171)  | [@jonen10](https://github.com/jonen10)
1.13.0       | [#166](https://github.com/locp/cassandra/pull/166)  | [@Mike-Petersen](https://github.com/Mike-Petersen)
1.13.0       | [#163](https://github.com/locp/cassandra/pull/163)  | [@VeriskPuppet](https://github.com/VeriskPuppet)
1.12.2       | [#165](https://github.com/locp/cassandra/pull/165)  | [@palmertime](https://github.com/palmertime)
1.12.0       | [#156](https://github.com/locp/cassandra/pull/156)  | [@stuartbfox](https://github.com/stuartbfox)
1.12.0       | [#153](https://github.com/locp/cassandra/pull/153)  | [@Mike-Petersen](https://github.com/Mike-Petersen)
1.10.0       | [#144](https://github.com/locp/cassandra/pull/144)  | [@Mike-Petersen](https://github.com/Mike-Petersen)
1.9.2        | [#136](https://github.com/locp/cassandra/issues/136)| [@mantunovic](https://github.com/mantunovic)
1.9.2        | [#136](https://github.com/locp/cassandra/issues/136)| [@al4](https://github.com/al4)
1.4.2        | [#110](https://github.com/locp/cassandra/pull/110)  | [@markasammut](https://github.com/markasammut)
1.4.0        | [#100](https://github.com/locp/cassandra/pull/100)  | [@markasammut](https://github.com/markasammut)
1.3.5        | [#93](https://github.com/locp/cassandra/issues/93)  | [@sampowers](https://github.com/sampowers)
1.3.3        | [#87](https://github.com/locp/cassandra/pull/87)    | [@DylanGriffith](https://github.com/DylanGriffith)
0.4.2        | [#34](https://github.com/locp/cassandra/pull/34)    | [@amosshapira](https://github.com/amosshapira)
0.3.0        | [#11](https://github.com/locp/cassandra/pull/11)    | [@spredzy](https://github.com/Spredzy)
