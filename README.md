# Cassandra

[![CI](https://github.com/voxpupuli/puppet-cassandra/actions/workflows/ci.yml/badge.svg)](https://github.com/voxpupuli/puppet-cassandra/actions/workflows/ci.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/cassandra.svg)](https://forge.puppetlabs.com/puppet/cassandra)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/cassandra.svg)](https://forge.puppetlabs.com/puppet/cassandra)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/cassandra.svg)](https://forge.puppetlabs.com/puppet/cassandra)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/cassandra.svg)](https://forge.puppetlabs.com/puppet/cassandra)

## Table of Contents

- [Cassandra](#cassandra)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Setup](#setup)
    - [What Cassandra affects](#what-cassandra-affects)
      - [What the Cassandra class affects](#what-the-cassandra-class-affects)
      - [What the cassandra::apache\_repo class affects](#what-the-cassandraapache_repo-class-affects)
      - [What the cassandra::java class affects](#what-the-cassandrajava-class-affects)
      - [What the cassandra::optutils class affects](#what-the-cassandraoptutils-class-affects)
    - [Beginning with Cassandra](#beginning-with-cassandra)
    - [Hiera](#hiera)
  - [Usage](#usage)
    - [Setup a keyspace and users](#setup-a-keyspace-and-users)
    - [Create a Cluster in a Single Data Center](#create-a-cluster-in-a-single-data-center)
    - [Create a Cluster in Multiple Data Centers](#create-a-cluster-in-multiple-data-centers)
  - [Reference](#reference)
  - [Limitations](#limitations)
  - [Development](#development)
    - [Additional Contributers](#additional-contributers)

## Overview

Module to install, configure and manage Cassandra.

## Setup

### What Cassandra affects

#### What the Cassandra class affects

- Installs the Cassandra package.
- Configures settings in `${config_path}/cassandra.yaml`.
- Optionally ensures that the Cassandra service is enabled and running.

#### What the cassandra::apache_repo class affects

- Optionally configures a Yum repository to install the Cassandra packages
  from (on Red Hat).
- Optionally configures an Apt repository to install the Cassandra packages
  from (on Debian).

#### What the cassandra::java class affects

- Optionally installs a JRE/JDK package (e.g. java-1.7.0-openjdk) and the
  Java Native Access (JNA).

#### What the cassandra::optutils class affects

- Optionally installs the Cassandra support tools (e.g. cassandra22-tools).

### Beginning with Cassandra

Create a cassandra cluster called MyCassandraCluster which uses the
GossipingPropertyFileSnitch and password authentication.  In this very
basic example the node itself becomes a seed for the cluster and the
credentials will default to a user called cassandra with a password
called of cassandra.

```puppet
# Cassandra pre-requisites
include cassandra::apache_repo
include cassandra::java

class { 'cassandra':
  baseline_settings => {
    authenticator               => 'AllowAllAuthenticator',
    authorizer                  => 'AllowAllAuthorizer',
    cluster_name                => 'MyCassandraCluster',
    commitlog_sync              => 'periodic',
    commitlog_sync_period_in_ms => 10000,
    listen_interface            => $facts['networking']['primary'],
    endpoint_snitch             => 'SimpleSnitch',
    partitioner                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
    seed_provider               => [
      {
        class_name => 'org.apache.cassandra.locator.SimpleSeedProvider',
        parameters => [
          {
            seeds => $facts['networking']['ip']
          },
        ],
      },
    ],
  },
  require  => Class['cassandra::apache_repo', 'cassandra::java'],
}
```

However, **PLEASE** note that this is the **ABSOLUTE MINIMUM** configuration
to get Cassandra up and running but will probably give you a rather badly
configured node.  Please see
[Suggested Baseline Settings](https://github.com/voxpupuli/puppet-cassandra/wiki/Suggested-Baseline-Settings)
for details on making your configuration a lot more robust.

### Hiera

In your top level node classification (usually `common.yaml`), add the
settings hash and all the tweaks you want all the clusters to use:

```YAML
cassandra::baseline_settings:
  authenticator: AllowAllAuthenticator
  authorizer: AllowAllAuthorizer
  auto_bootstrap: true
  auto_snapshot: true
  ...
```

Then, in the individual node classification add the parts which define
the cluster:

```YAML
cassandra::settings:
  cluster_name: developer playground cassandra cluster
cassandra::dc: Onsite1
cassandra::rack: RAC1
cassandra::package_ensure: 3.0.5-1
cassandra::package_name: cassandra30
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
  cqlsh_host     => $facts['networking']['ip'],
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
  permissions    => {
    'Grant select permissions to spillman to all keyspaces' => {
      permission_name => 'SELECT',
      user_name       => 'spillman',
    },
    'Grant modify to to keyspace mykeyspace to akers'       => {
      keyspace_name   => 'mykeyspace',
      permission_name => 'MODIFY',
      user_name       => 'akers',
    },
    'Grant alter permissions to mykeyspace to boone'        => {
      keyspace_name   => 'mykeyspace',
      permission_name => 'ALTER',
      user_name       => 'boone',
    },
    'Grant ALL permissions to mykeyspace.users to gbennet'  => {
      keyspace_name   => 'mykeyspace',
      permission_name => 'ALTER',
      table_name      => 'users',
      user_name       => 'gbennet',
    },
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
    'gbennet'  => {
      'password' => 'foobar',
    },
    'lucan'    => {
      'ensure' => absent
    },
  },
}
```

### Create a Cluster in a Single Data Center

This is a basic example of a six node cluster with two seeds to be created in
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

- Ensuring that the software is installed by including `cassandra::apache_repo`.
  This needs to be executed before the Cassandra package is installed.
- That a suitable Java Runtime environment (JRE) is installed with Java Native
  Access (JNA) by including `cassandra::java`.  This need to be executed
  before the Cassandra service is started.

```puppet
node /^node\d+$/ {
  class { 'cassandra::apache_repo':
    before => Class['cassandra']
  }

  class { 'cassandra::java':
    before => Class['cassandra']
  }

  class { 'cassandra':
    settings       => {
      'authenticator'               => 'AllowAllAuthenticator',
      'auto_bootstrap'              => false,
      'cluster_name'                => 'MyCassandraCluster',
      'commitlog_directory'         => '/var/lib/cassandra/commitlog',
      'commitlog_sync'              => 'periodic',
      'commitlog_sync_period_in_ms' => 10000,
      'data_file_directories'       => ['/var/lib/cassandra/data'],
      'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
      'hints_directory'             => '/var/lib/cassandra/hints',
      'listen_interface'            => 'eth1',
      'num_tokens'                  => 256,
      'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
      'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
      'seed_provider'               => [
        {
          'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
          'parameters' => [
            {
              'seeds' => '110.82.155.0,110.82.156.3',
            },
          ],
        },
      ],
      'start_native_transport'      => true,
    },
  }
}
```

The default value for the num_tokens is already 256, but it is
included in the example for clarity.  Do not forget to either
set auto_bootstrap to true or not set the attribute at all
after initializing the cluster.

### Create a Cluster in Multiple Data Centers

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
    dc             => 'DC1',
    settings       => {
      'authenticator'               => 'AllowAllAuthenticator',
      'auto_bootstrap'              => false,
      'cluster_name'                => 'MyCassandraCluster',
      'commitlog_directory'         => '/var/lib/cassandra/commitlog',
      'commitlog_sync'              => 'periodic',
      'commitlog_sync_period_in_ms' => 10000,
      'data_file_directories'       => ['/var/lib/cassandra/data'],
      'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
      'hints_directory'             => '/var/lib/cassandra/hints',
      'listen_interface'            => 'eth1',
      'num_tokens'                  => 256,
      'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
      'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
      'seed_provider'               => [
        {
          'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
          'parameters' => [
            {
              'seeds' => '110.82.155.0,110.82.156.3',
            },
          ],
        },
      ],
      'start_native_transport'      => true,
    },
  }
}

node /^node[345]$/ {
  class { 'cassandra':
    dc             => 'DC2',
    settings       => {
      'authenticator'               => 'AllowAllAuthenticator',
      'auto_bootstrap'              => false,
      'cluster_name'                => 'MyCassandraCluster',
      'commitlog_directory'         => '/var/lib/cassandra/commitlog',
      'commitlog_sync'              => 'periodic',
      'commitlog_sync_period_in_ms' => 10000,
      'data_file_directories'       => ['/var/lib/cassandra/data'],
      'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
      'hints_directory'             => '/var/lib/cassandra/hints',
      'listen_interface'            => 'eth1',
      'num_tokens'                  => 256,
      'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
      'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
      'seed_provider'               => [
        {
          'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
          'parameters' => [
            {
              'seeds' => '110.82.155.0,110.82.156.3',
            },
          ],
        },
      ],
      'start_native_transport'      => true,
    },
  }
}
```

We don't need to specify the rack name (with the rack attribute) as RAC1 is
the default value.  Again, do not forget to either set auto_bootstrap to
true or not set the attribute at all after initializing the cluster.

## Reference

The reference documentation is generated using the
[puppet-strings](https://github.com/puppetlabs/puppet-strings) tool.  To see
all of it, please go to
[http://voxpupuli.github.io/puppet-cassandra](http://voxpupuli.github.io/puppet-cassandra/_index.html).

## Limitations

- When creating key spaces, indexes, cql_types and users the settings will only
be used to create a new resource if it does not currently exist.  If a change
is made to the Puppet manifest but the resource already exits, this change
will not be reflected.

## Development

Contributions will be gratefully accepted.  Please go to the project page,
fork the project, make your changes locally and then raise a pull request.
Details on how to do this are available at
https://guides.github.com/activities/contributing-to-open-source.

Please also see the
[CONTRIBUTING.md](./CONTRIBUTING.md)
page for project specific requirements.

### Additional Contributers

For a list of contributers see
[CONTRIBUTING.md](./CONTRIBUTING.md)
and https://github.com/voxpupuli/puppet-cassandra/graphs/contributors
