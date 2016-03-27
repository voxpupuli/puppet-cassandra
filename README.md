# Cassandra
[![Puppet Forge](http://img.shields.io/puppetforge/v/locp/cassandra.svg)](https://forge.puppetlabs.com/locp/cassandra)
[![Github Tag](https://img.shields.io/github/tag/locp/cassandra.svg)](https://github.com/locp/cassandra)
[![Build Status](https://travis-ci.org/locp/cassandra.png?branch=master)](https://travis-ci.org/locp/cassandra)
[![Coverage Status](https://coveralls.io/repos/locp/cassandra/badge.svg?branch=master&service=github)](https://coveralls.io/github/locp/cassandra?branch=master)
[![Join the chat at https://gitter.im/locp/cassandra](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/locp/cassandra?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with Cassandra](#setup)
    * [What Cassandra affects](#what-cassandra-affects)
    * [Beginning with Cassandra](#beginning-with-cassandra)
    * [Upgrading](#upgrading)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Create a Cluster in a Single Data Center](#create-a-cluster-in-a-single-data-center)
    * [Create a Cluster in Multiple Data Centers](#create-a-cluster-in-multiple-data-centers)
    * [OpsCenter](#opscenter)
    * [DataStax Enterprise](#datastax-enterprise)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [cassandra](#class-cassandra)
    * [cassandra::datastax_agent](#class-cassandradatastax_agent)
    * [cassandra::datastax_repo](#class-cassandradatastax_repo)
    * [cassandra::firewall_ports](#class-cassandrafirewall_ports)
    * [cassandra::java](#class-cassandrajava)
    * [cassandra::opscenter](#class-cassandraopscenter)
    * [cassandra::opscenter::cluster_name](#defined-type-cassandraopscentercluster_name)
    * [cassandra::opscenter::pycrypto](#class-cassandraopscenterpycrypto)
    * [cassandra::optutils](#class-cassandraoptutils)
    * [cassandra::schema](#class-cassandraschema)
    * [cassandra::schema::cql_type](#defined-type-cassandraschemacql_type)
    * [cassandra::schema::index](#defined-type-cassandraschemaindex)
    * [cassandra::schema::keyspace](#defined-type-cassandraschemakeyspace)
    * [cassandra::schema::table](#defined-type-cassandraschematable)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Contributers](#contributers)

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
* On Ubuntu systems, optionally replace ```/etc/init.d/cassandra``` with a
  workaround for
  [CASSANDRA-9822](https://issues.apache.org/jira/browse/CASSANDRA-9822).
* Optionally creates a file /usr/lib/systemd/system/cassandra.service to
  improve service interaction on the RedHat family or
  /lib/systemd/system/cassandra.service on the Debian family.

#### What the cassandra::datastax_agent class affects

* Optionally installs the DataStax agent.
* Optionally sets JAVA_HOME in **/etc/default/datastax-agent**.
* Optionally creates a file /usr/lib/systemd/system/datastax-agent.service to
  improve service interaction on the RedHat family or
  /lib/systemd/system/datastax-agent.service on the Debian family.

#### What the cassandra::datastax_agent class affects

* Optionally configures a Yum repository to install the Cassandra packages
  from (on Red Hat).
* Optionally configures an Apt repository to install the Cassandra packages
  from (on Ubuntu).

#### What the cassandra::firewall_ports class affects

* Optionally configures the firewall for the Cassandra related network
  ports.

#### What the cassandra::java class affects

* Optionally installs a JRE/JDK package (e.g. java-1.7.0-openjdk) and the
  Java Native Access (JNA).

#### What the cassandra::opscenter class affects

* Installs the OpsCenter package.
* Manages the content of the configuration file
  (/etc/opscenter/opscenterd.conf).
* Manages the opscenterd service.
* Optionally creates a file /usr/lib/systemd/system/opscenterd.service to
  improve service interaction on the RedHat family or
  /lib/systemd/system/opscenterd.service on the Debian family.

#### What the cassandra::opscenter::cluster_name type affects

* An optional type that allows DataStax OpsCenter to connect to a remote
  key space for metrics storage.  These files will be created in
  /etc/opscenter/clusters.  The module also creates this directory if
  required.  This functionality is only valid in DataStax Enterprise.
* Optionally purge any none Puppet controlled clusters from
  /etc/opscenter/clusters.

#### What the cassandra::opscenter::pycrypto class affects

* On the Red Hat family it installs the pycrypto library and it's
  pre-requisites (the python-devel and python-pip packages).
* Optionally installs the Extra Packages for Enterprise Linux (EPEL)
  repository.
* As a workaround for
  [PUP-3829](https://tickets.puppetlabs.com/browse/PUP-3829) a symbolic
  link is created from ```/usr/bin/pip``` to
  ```/usr/bin/pip-python```.  Hopefully this can be removed in the not
  too distant future.

#### What the cassandra::optutils class affects

* Optionally installs the Cassandra support tools (e.g. cassandra22-tools).

### Beginning with Cassandra

This code will install Cassandra onto a system and create a basic
keyspace, table and index.

```puppet
# Cassandra pre-requisites.  You may want to install your own Java
# environment.
include cassandra::datastax_repo
include cassandra::java

# Install Cassandra on the node.  In this example, the node itself becomes
# a seed for the cluster.
class { 'cassandra':
  cluster_name    => 'MyCassandraCluster',
  endpoint_snitch => 'GossipingPropertyFileSnitch',
  listen_address  => $::ipaddress,
  seeds           => $::ipaddress,
  service_systemd => true,
  require         => Class['cassandra::datastax_repo', 'cassandra::java'],
}

# Create a keyspace.
cassandra::schema::keyspace { 'mykeyspace':
  replication_map => {
    keyspace_class     => 'SimpleStrategy',
    replication_factor => 1,
  },
  durable_writes  => false,
}

# Create a table within the keyspace.
cassandra::schema::table { 'users':
  columns  => {
    user_id       => 'int',
    fname         => 'text',
    lname         => 'text',
    'PRIMARY KEY' => '(user_id)',
  },
  keyspace => 'mykeyspace',
}

# Add an index to the table.
cassandra::schema::index { 'users_lname_idx':
  table    => 'users',
  keys     => 'lname',
  keyspace => 'mykeyspace',
}
```

This is how one would implement the example for getting started with Cassandra
shown in
http://wiki.apache.org/cassandra/GettingStarted (viewed 27-Mar-2016) using
this Puppet module.

### Upgrading

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

## Usage

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

### OpsCenter

To continue with the original example within a single data center, say we
have an instance of OpsCenter running on a node called opscenter which has
an IP address of 110.82.157.6.  We add the `cassandra::datastax_agent` to
the cassandra node to connect to OpsCenter:

```puppet
node /^node\d+$/ {
  class { 'cassandra::datastax_repo':
    before => Class['cassandra']
  } ->
  class { 'cassandra::java':
    before => Class['cassandra']
  } ->
  class { 'cassandra':
    cluster_name    => 'MyCassandraCluster',
    endpoint_snitch => 'GossipingPropertyFileSnitch',
    listen_address  => "${::ipaddress}",
    num_tokens      => 256,
    seeds           => '110.82.155.0,110.82.156.3',
    before          => Class['cassandra::datastax_agent']
  } ->
  class { 'cassandra::datastax_agent':
    stomp_interface => '110.82.157.6'
  }
}

node /opscenter/ {
  class { '::cassandra::datastax_repo': } ->
  class { '::cassandra': } ->
  class { '::cassandra::opscenter': }
}
```

We have also added the `cassandra::opscenter` class for the opscenter node.

### DataStax Enterprise

After configuring the relevant repository, the following snippet works on
CentOS 7 to install DSE Cassandra 4.7.0:

```puppet
class { 'cassandra::datastax_repo':
  descr   => 'DataStax Repo for DataStax Enterprise',
  pkg_url => 'https://username:password@rpm.datastax.com/enterprise',
  before  => Class['cassandra'],
}

class { 'cassandra':
  cluster_name    => 'MyCassandraCluster',
  config_path     => '/etc/dse/cassandra',
  package_ensure  => '4.7.0-1',
  package_name    => 'dse-full',
  service_name    => 'dse',
  service_systemd => true
}
```

Also with DSE, one can specify a remote keyspace for storing the metrics for
a cluster.  An example is:

```puppet
cassandra::opscenter::cluster_name { 'Cluster1':
  cassandra_seed_hosts       => 'host1,host2',
  storage_cassandra_username => 'opsusr',
  storage_cassandra_password => 'opscenter',
  storage_cassandra_api_port => 9160,
  storage_cassandra_cql_port => 9042,
  storage_cassandra_keyspace => 'OpsCenter_Cluster1'
}
```

## Reference

### Public Classes

* [cassandra](#class-cassandra)
* [cassandra::datastax_agent](#class-cassandradatastax_agent)
* [cassandra::datastax_repo](#class-cassandradatastax_repo)
* [cassandra::firewall_ports](#class-cassandrafirewall_ports)
* [cassandra::java](#class-cassandrajava)
* [cassandra::opscenter](#class-cassandraopscenter)
* [cassandra::opscenter::pycrypto](#class-cassandraopscenterpycrypto)
* [cassandra::optutils](#class-cassandraoptutils)
* [cassandra::schema](#class-cassandraschema)

### Public Defined Types
* [cassandra::opscenter::cluster_name](#defined-type-cassandraopscentercluster_name)

### Private Defined Types

* cassandra::private::data_directory
* cassandra::private::deprecation_warning
* cassandra::private::firewall_ports::rule
* cassandra::private::opscenter::setting

### Class: cassandra

A class for installing the Cassandra package and manipulate settings in the
configuration file.

#### Attributes

##### `additional_lines`
An optional array of user specified lines that are appended to the end of the
Cassandra configuration file.

Default value: []

##### `authenticator`
Authentication backend, implementing IAuthenticator; used to identify users.
Out of the box, Cassandra provides
org.apache.cassandra.auth.{AllowAllAuthenticator, PasswordAuthenticator}.

* AllowAllAuthenticator performs no checks - set it to disable authentication.
* PasswordAuthenticator relies on username/password pairs to authenticate
  users. It keeps usernames and hashed passwords in system_auth.credentials
  table.  Please increase system_auth keyspace replication factor if you use
  this authenticator.

Default value: 'AllowAllAuthenticator.

##### `authorizer`
Authorization backend, implementing IAuthorizer; used to limit access/provide
permissions.  Out of the box, Cassandra provides
org.apache.cassandra.auth.{AllowAllAuthorizer, CassandraAuthorizer}.

- AllowAllAuthorizer allows any action to any user - set it to disable
  authorization.
- CassandraAuthorizer stores permissions in system_auth.permissions table.
  Please increase system_auth keyspace replication factor if you use this
  authorizer.

Default value: 'AllowAllAuthorizer'

##### `auto_bootstrap`
This setting if set to true makes new (non-seed) nodes automatically migrate
the right data to themselves. When initializing a fresh cluster without data,
set this value to false.  If left at the default value of *undef* then the
entry in the configuration file is absent or commented out.  If a value is
set, then the attribute and variable are placed into the configuration file.
Default value: *undef*

##### `auto_snapshot`
Whether or not a snapshot is taken of the data before keyspace truncation
or dropping of column families. The STRONGLY advised default of true
should be used to provide data safety. If you set this flag to false, you will
lose data on truncation or drop.
Default value **true**

##### `batchlog_replay_throttle_in_kb`
Maximum throttle in KBs per second, total. This will be reduced proportionally
to the number of nodes in the cluster.
Default value: '1024'

##### `batch_size_warn_threshold_in_kb`
Log WARN on any batch size exceeding this value. 5kb per batch by default.
Caution should be taken on increasing the size of this threshold as it can
lead to node instability.
Default value 5

##### `broadcast_address`
Address to broadcast to other Cassandra nodes. Leaving this value as the
default will set it to the same value as `listen_address`.
Default value: *undef*

##### `broadcast_rpc_address`
RPC address to broadcast to drivers and other Cassandra nodes. This cannot
be set to 0.0.0.0. If left as the default value it will be set to the value
of `rpc_address`.  If `rpc_address` is set to 0.0.0.0, broadcast_rpc_address
must be set.
Default value: *undef*

##### `cas_contention_timeout_in_ms`
How long a coordinator should continue to retry a CAS operation
that contends with other proposals for the same row.
Default value: '1000'

##### `cassandra_9822`
If set to true, this will apply a patch to the init file for the Cassandra
service as a workaround for
[CASSANDRA-9822](https://issues.apache.org/jira/browse/CASSANDRA-9822).  This
option is silently ignored on the Red Hat family of operating systems as
this bug only affects Ubuntu systems.
Default value 'false'

##### `cassandra_yaml_tmpl`
The path to the Puppet template for the Cassandra configuration file.  This
allows the user to supply their own customized template.  A Cassandra 1.X
compatible template called cassandra1.yaml.erb has been provided by @Spredzy.
There is also cassandra20.yaml.erb that is more suitable for use with
Cassandra 2.0.
Default value 'cassandra/cassandra.yaml.erb'

##### `client_encryption_algorithm`
Sets `client_encryption_options -> algorithm`.
Default value: *undef*

Part of the client encryption options.  See also
`client_encryption_enabled`,
`client_encryption_keystore`,
`client_encryption_keystore_password`,
`client_encryption_require_client_auth`,
`client_encryption_truststore`,
`client_encryption_truststore_password`,
`client_encryption_protocol`,
`client_encryption_store_type`,
`client_encryption_cipher_suites`.

##### `client_encryption_cipher_suites`
Sets `client_encryption_options -> cipher_suites`.
Default value: *undef*

Part of the client encryption options.  See also
`client_encryption_algorithm`,
`client_encryption_enabled`,
`client_encryption_keystore`,
`client_encryption_keystore_password`,
`client_encryption_require_client_auth`,
`client_encryption_truststore`,
`client_encryption_truststore_password`,
`client_encryption_protocol`,
`client_encryption_store_type`.

##### `client_encryption_enabled`
Sets `client_encryption_options -> enabled`.
Default value 'false'

Part of the client encryption options.  See also
`client_encryption_algorithm`,
`client_encryption_keystore`,
`client_encryption_keystore_password`,
`client_encryption_require_client_auth`,
`client_encryption_truststore`,
`client_encryption_truststore_password`,
`client_encryption_protocol`,
`client_encryption_store_type`,
`client_encryption_cipher_suites`.

##### `client_encryption_keystore`
Sets `client_encryption_options -> keystore`.
Default value 'conf/.keystore'

Part of the client encryption options.  See also
`client_encryption_algorithm`,
`client_encryption_enabled`,
`client_encryption_keystore_password`,
`client_encryption_require_client_auth`,
`client_encryption_truststore`,
`client_encryption_truststore_password`,
`client_encryption_protocol`,
`client_encryption_store_type`,
`client_encryption_cipher_suites`.

##### `client_encryption_keystore_password`
Sets `client_encryption_options -> keystore_password`.
Default value 'cassandra'

Part of the client encryption options.  See also
`client_encryption_algorithm`,
`client_encryption_enabled`,
`client_encryption_keystore`,
`client_encryption_require_client_auth`,
`client_encryption_truststore`,
`client_encryption_truststore_password`,
`client_encryption_protocol`,
`client_encryption_store_type`,
`client_encryption_cipher_suites`.

##### `client_encryption_protocol`
Sets `client_encryption_options -> protocol`.
Default value: *undef*

Part of the client encryption options.  See also
`client_encryption_algorithm`,
`client_encryption_enabled`,
`client_encryption_keystore`,
`client_encryption_keystore_password`,
`client_encryption_require_client_auth`,
`client_encryption_truststore`,
`client_encryption_truststore_password`,
`client_encryption_store_type`,
`client_encryption_cipher_suites`.

##### `client_encryption_require_client_auth`
Sets `client_encryption_options -> require_client_auth`.
Default value: *undef*

Part of the client encryption options.  See also
`client_encryption_algorithm`,
`client_encryption_enabled`,
`client_encryption_keystore`,
`client_encryption_keystore_password`,
`client_encryption_truststore`,
`client_encryption_truststore_password`,
`client_encryption_protocol`,
`client_encryption_store_type`,
`client_encryption_cipher_suites`.

##### `client_encryption_store_type`
Sets `client_encryption_options -> store_type`.
Default value: *undef*

Part of the client encryption options.  See also
`client_encryption_algorithm`,
`client_encryption_enabled`,
`client_encryption_keystore`,
`client_encryption_keystore_password`,
`client_encryption_require_client_auth`,
`client_encryption_truststore`,
`client_encryption_truststore_password`,
`client_encryption_protocol`,
`client_encryption_cipher_suites`.

##### `client_encryption_truststore`
Sets `client_encryption_options -> truststore`.
Default value: *undef*

Part of the client encryption options.  See also
`client_encryption_algorithm`,
`client_encryption_enabled`,
`client_encryption_keystore`,
`client_encryption_keystore_password`,
`client_encryption_require_client_auth`,
`client_encryption_truststore_password`,
`client_encryption_protocol`,
`client_encryption_store_type`,
`client_encryption_cipher_suites`.

##### `client_encryption_truststore_password`
Sets `client_encryption_options -> truststore_password`.
Default value: *undef*

Part of the client encryption options.  See also
`client_encryption_algorithm`,
`client_encryption_enabled`,
`client_encryption_keystore`,
`client_encryption_keystore_password`,
`client_encryption_require_client_auth`,
`client_encryption_truststore`,
`client_encryption_protocol`,
`client_encryption_store_type`,
`client_encryption_cipher_suites`.

##### `cluster_name`
The name of the cluster. This is mainly used to prevent machines in one
logical cluster from joining another.
Default value 'Test Cluster'

##### `column_index_size_in_kb`
Granularity of the collation index of rows within a partition.
Increase if your rows are large, or if you have a very large
number of rows per partition.  The competing goals are these:

1. a smaller granularity means more index entries are generated
   and looking up rows withing the partition by collation column
   is faster
2. but, Cassandra will keep the collation index in memory for hot
   rows (as part of the key cache), so a larger granularity means
   you can cache more hot rows

Default value: '64'

##### `commit_failure_policy`
Policy for commit disk failures:
* die: shut down gossip and Thrift and kill the JVM, so the node can be replaced.
* stop: shut down gossip and Thrift, leaving the node effectively dead, but
        can still be inspected via JMX.
* stop_commit: shutdown the commit log, letting writes collect but
               continuing to service reads, as in pre-2.0.5 Cassandra
* ignore: ignore fatal errors and let the batches fail

Default value: 'stop'

##### `commitlog_directory`
When running on magnetic HDD, this should be a separate spindle than the data
directories.
Default value '/var/lib/cassandra/commitlog'

See also `data_file_directories` and `saved_caches_directory`.

##### `commitlog_directory_mode`
The mode for the directory specified in `commitlog_directory`.
Default value '0750'

##### `commitlog_segment_size_in_mb`
The size of the individual commitlog file segments.  A commitlog
segment may be archived, deleted, or recycled once all the data
in it (potentially from each columnfamily in the system) has been
flushed to sstables.

The default size is 32, which is almost always fine, but if you are
archiving commitlog segments (see commitlog_archiving.properties),
then you probably want a finer granularity of archiving; 8 or 16 MB
is reasonable.

Default value: 32

##### `commitlog_sync`
May be either "periodic" or "batch." When in batch mode, Cassandra won't ack
writes until the commit log has been fsynced to disk. It will wait up to
commitlog_sync_batch_window_in_ms milliseconds for other writes, before
performing the sync.
Default value: 'periodic'

See also `commitlog_sync_batch_window_in_ms` and `commitlog_sync_period_in_ms`.

##### `commitlog_sync_batch_window_in_ms`
If `commitlog_sync` is set to 'batch' then this value should be set.
Otherwise it should be set to *undef*.
Default value: *undef*

##### `commitlog_sync_period_in_ms`
If `commitlog_sync` is set to 'periodic' then this value should be set.
Otherwise it should be set to *undef*.
Default value: 10000

##### `commitlog_total_space_in_mb`
Total space to use for commitlogs.  Since commitlog segments are
mmapped, and hence use up address space, the default size is 32
on 32-bit JVMs, and 8192 on 64-bit JVMs (calculated automatically by
cassandra if the module setting is left at *undef*).

If space gets above this value (it will round up to the next nearest
segment multiple), Cassandra will flush every dirty CF in the oldest
segment and remove it.  So a small total commitlog space will tend
to cause more flush activity on less-active columnfamilies.
Default value: *undef*

##### `compaction_throughput_mb_per_sec`
Throttles compaction to the given total throughput across the entire
system. The faster you insert data, the faster you need to compact in
order to keep the sstable count down, but in general, setting this to
16 to 32 times the rate you are inserting data is more than sufficient.
Setting this to 0 disables throttling. Note that this accounts for all types
of compaction, including validation compaction.
Default value: '16'

##### `concurrent_counter_writes`
For workloads with more data than can fit in memory, Cassandra's
bottleneck will be reads that need to fetch data from
disk. `concurrent_reads` should be set to (16 * number_of_drives) in
order to allow the operations to enqueue low enough in the stack
that the OS and drives can reorder them. Same applies to
`concurrent_counter_writes`, since counter writes read the current
values before incrementing and writing them back.

On the other hand, since writes are almost never IO bound, the ideal
number of `concurrent_writes` is dependent on the number of cores in
your system; (8 * number_of_cores) is a good rule of thumb.
Default value '32'

##### `concurrent_reads`
See `concurrent_counter_writes`.
Default value '32'

##### `concurrent_writes`
See `concurrent_counter_writes`.
Default value '32'

##### `config_file_mode`
The permissions mode of the cassandra configuration file.
Default value '0644'

##### `config_path`
The path to the cassandra configuration file.
Default value **/etc/cassandra/default.conf** on Red Hat
or **/etc/cassandra** on Debian.

##### `concurrent_compactors`
Number of simultaneous compactions to allow, NOT including
validation "compactions" for anti-entropy repair.  Simultaneous
compactions can help preserve read performance in a mixed read/write
workload, by mitigating the tendency of small sstables to accumulate
during a single long running compactions. The default (*undef*) is usually
fine and if you experience problems with compaction running too
slowly or too fast, you should look at
`compaction_throughput_mb_per_sec` first.

`concurrent_compactors` defaults to the smaller of (number of disks,
number of cores), with a minimum of 2 and a maximum of 8.

If your data directories are backed by SSD, you should increase this
to the number of cores.
Default value: *undef*

##### `counter_cache_save_period`
Duration in seconds after which Cassandra should save the counter cache (keys
only). Caches are saved to saved_caches_directory as specified in this
configuration file.
Default value: '7200' (2 hours)

##### `counter_cache_keys_to_save`
Number of keys from the counter cache to save.  Disabled by default
(*undef*), meaning all keys are going to be saved.
Default value: *undef*

##### `counter_cache_size_in_mb`
Maximum size of the counter cache in memory.

Counter cache helps to reduce counter locks' contention for hot counter cells.
In case of RF = 1 a counter cache hit will cause Cassandra to skip the read
before write entirely. With RF > 1 a counter cache hit will still help to
reduce the duration of the lock hold, helping with hot counter cell updates,
but will not allow skipping the read entirely. Only the local (clock, count)
tuple of a counter cell is kept in memory, not the whole counter, so it's
relatively cheap.

NOTE: if you reduce the size, you may not get you hottest keys loaded on
startup.

Default value is empty to make it "auto" (min(2.5% of Heap (in MB), 50MB)).
Set to 0 to disable counter cache.  NOTE: if you perform counter deletes and
rely on low gcgs, you should disable the counter cache.
Default value: ''

##### `counter_write_request_timeout_in_ms`
How long the coordinator should wait for counter writes to complete.
Default value: '5000'

##### `cross_node_timeout`
Enable operation timeout information exchange between nodes to accurately
measure request timeouts.  If disabled, replicas will assume that requests
were forwarded to them instantly by the coordinator, which means that
under overload conditions we will waste that much extra time processing
already-timed-out requests.

Warning: before enabling this property make sure that ntp is installed
and the times are synchronized between the nodes.
Default value: 'false'

##### `data_file_directories`
Directories where Cassandra should store data on disk.  Cassandra
will spread data evenly across them, subject to the granularity of
the configured compaction strategy.

Default value '['/var/lib/cassandra/data']'

See also `commitlog_directory` and `saved_caches_directory`.

##### `data_file_directories_mode`
The mode for the directories specified in `data_file_directories`.
Default value '0750'

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

##### `disk_failure_policy`
Policy for data disk failures:
* die: shut down gossip and Thrift and kill the JVM for any fs errors or
       single-sstable errors, so the node can be replaced.
* stop_paranoid: shut down gossip and Thrift even for single-sstable errors.
* stop: shut down gossip and Thrift, leaving the node effectively dead, but
        can still be inspected via JMX.
* best_effort: stop using the failed disk and respond to requests based on
               remaining available sstables.  This means you WILL see obsolete
               data at CL.ONE!
* ignore: ignore fatal errors and let requests fail, as in pre-1.2 Cassandra

Default value 'stop'

##### `dynamic_snitch_badness_threshold`
if set greater than zero and read_repair_chance is < 1.0, this will allow
'pinning' of replicas to hosts in order to increase cache capacity.
The badness threshold will control how much worse the pinned host has to be
before the dynamic snitch will prefer other replicas over it.  This is
expressed as a double which represents a percentage.  Thus, a value of
0.2 means Cassandra would continue to prefer the static snitch values
until the pinned host was 20% worse than the fastest.
Default value: '0.1'

##### `dynamic_snitch_reset_interval_in_ms`
Controls how often to reset all host scores, allowing a bad host to
possibly recover.
Default value: '600000'

##### `dynamic_snitch_update_interval_in_ms`
Controls how often to perform the more expensive part of host score calculation.
Default value: '100'

##### `endpoint_snitch`
Set this to a class that implements IEndpointSnitch.  The snitch has two functions:
1. It teaches Cassandra enough about your network topology to route requests
   efficiently.
2. It allows Cassandra to spread replicas around your cluster to avoid
   correlated failures. It does this by grouping machines into
   "datacenters" and "racks."  Cassandra will do its best not to have
   more than one replica on the same "rack" (which may not actually
   be a physical location)

IF YOU CHANGE THE SNITCH AFTER DATA IS INSERTED INTO THE CLUSTER,
YOU MUST RUN A FULL REPAIR, SINCE THE SNITCH AFFECTS WHERE REPLICAS
ARE PLACED.

Out of the box, Cassandra provides:
* SimpleSnitch:
  Treats Strategy order as proximity. This can improve cache
  locality when disabling read repair.  Only appropriate for
  single-datacenter deployments.
* GossipingPropertyFileSnitch:
  This should be your go-to snitch for production use.  The rack
  and datacenter for the local node are defined in
  cassandra-rackdc.properties and propagated to other nodes via
  gossip.  If cassandra-topology.properties exists, it is used as a
  fallback, allowing migration from the PropertyFileSnitch.
* PropertyFileSnitch:
  Proximity is determined by rack and data center, which are
  explicitly configured in cassandra-topology.properties.
* Ec2Snitch:
  Appropriate for EC2 deployments in a single Region. Loads Region
  and Availability Zone information from the EC2 API. The Region is
  treated as the datacenter, and the Availability Zone as the rack.
  Only private IPs are used, so this will not work across multiple
  Regions.
* Ec2MultiRegionSnitch:
  Uses public IPs as broadcast_address to allow cross-region
  connectivity.  (Thus, you should set seed addresses to the public
  IP as well.) You will need to open the storage_port or
  ssl_storage_port on the public IP firewall.  (For intra-Region
  traffic, Cassandra will switch to the private IP after
  establishing a connection.)
* RackInferringSnitch:
  Proximity is determined by rack and data center, which are
  assumed to correspond to the 3rd and 2nd octet of each node's IP
  address, respectively.  Unless this happens to match your
  deployment conventions, this is best used as an example of
  writing a custom Snitch class and is provided in that spirit.

You can use a custom Snitch by setting this to the full class name
of the snitch, which will be assumed to be on your classpath.
Default value 'SimpleSnitch'

##### `fail_on_non_supported_os`
A flag that dictates if the module should fail if it is not RedHat or Debian.
If you set this option to false then you must also at least set the
`config_path` attribute as well.
Default value 'true'

##### `file_cache_size_in_mb`
Total memory to use for sstable-reading buffers.  If omitted defaults to
the smaller of 1/4 of heap or 512MB.
Default value: *undef*

##### `hinted_handoff_enabled`
See http://wiki.apache.org/cassandra/HintedHandoff
May either be "true" or "false" to enable globally, or contain a list
of data centers to enable per-datacenter (e.g. DC1,DC2).
Default value 'true'

##### `hinted_handoff_throttle_in_kb`
Maximum throttle in KBs per second, per delivery thread.  This will be
reduced proportionally to the number of nodes in the cluster.  (If there
are two nodes in the cluster, each delivery thread will use the maximum
rate; if there are three, each will throttle to half of the maximum,
since we expect two nodes to be delivering hints simultaneously.)
Default value: '1024'

##### `index_summary_capacity_in_mb`
A fixed memory pool size in MB for for SSTable index summaries. If left
empty, this will default to 5% of the heap size. If the memory usage of
all index summaries exceeds this limit, SSTables with low read rates will
shrink their index summaries in order to meet this limit.  However, this
is a best-effort process. In extreme conditions Cassandra may need to use
more than this amount of memory.
Default value: ''

##### `index_summary_resize_interval_in_minutes`
How frequently index summaries should be resampled.  This is done
periodically to redistribute memory from the fixed-size pool to sstables
proportional their recent read rates.  Setting to -1 will disable this
process, leaving existing index summaries at their current sampling level.
Default value: '60'

##### `incremental_backups`
Set to true to have Cassandra create a hard link to each sstable
flushed or streamed locally in a backups/ subdirectory of the
keyspace data.  Removing these links is the operator's
responsibility.
Default value 'false'

##### `initial_token`
Allows you to specify tokens manually.  While you can use
it with vnodes (num_tokens > 1, above) - in which case you should provide a
comma-separated list - it's primarily used when adding nodes
to legacy clusters that do not have vnodes enabled.
Default value: *undef*

##### `inter_dc_stream_throughput_outbound_megabits_per_sec`
Throttles all streaming file transfer between the data centers. This setting
allows throttles streaming throughput betweens data centers in addition to
throttling all network stream traffic as configured with
stream_throughput_outbound_megabits_per_sec.
Default value: *undef*

##### `inter_dc_tcp_nodelay`
Enable or disable tcp_nodelay for inter-dc communication.
Disabling it will result in larger (but fewer) network packets being sent,
reducing overhead from the TCP protocol itself, at the cost of increasing
latency if you block for cross-datacenter responses.
Default value: 'false'

##### `internode_authenticator`
Internode authentication backend, implementing IInternodeAuthenticator;
used to allow/disallow connections from peer nodes.
Default value: *undef*

##### `internode_compression`
Controls whether traffic between nodes is compressed.  Can be:
* all - all traffic is compressed
* dc   - traffic between different datacenters is compressed
* none - nothing is compressed.

Default value 'all'

##### `internode_recv_buff_size_in_bytes`
Change from the default to set socket buffer size for internode communication
Note that when setting this, the buffer size is limited by net.core.wmem_max
and when not setting it it is defined by net.ipv4.tcp_wmem

See:
* /proc/sys/net/core/wmem_max
* /proc/sys/net/core/rmem_max
* /proc/sys/net/ipv4/tcp_wmem
* /proc/sys/net/ipv4/tcp_wmem

and: man tcp

Default value: *undef*

##### `internode_send_buff_size_in_bytes`
See `internode_recv_buff_size_in_bytes`.
Default value: *undef*

##### `key_cache_save_period`
Duration in seconds after which Cassandra should
save the key cache. Caches are saved to saved_caches_directory as
specified in this configuration file.

Saved caches greatly improve cold-start speeds, and is relatively cheap in
terms of I/O for the key cache. Row cache saving is much more expensive and
has limited use.

Default value: 14400 (4 hours)

##### `key_cache_size_in_mb`
Default value is empty to make it "auto" (min(5% of Heap (in MB), 100MB)). Set
to 0 to disable key cache.
Default value: ''

##### `key_cache_keys_to_save`
Number of keys from the key cache to save.  Disabled by default, meaning all
keys are going to be saved.
Default value: *undef*

##### `listen_address`
Address or interface to bind to and tell other Cassandra nodes to connect to.
You **MUST** change this if you want multiple nodes to be able to communicate!

Set `listen_address` OR `listen_interface`, not both. Interfaces must correspond
to a single address, IP aliasing is not supported.

Leaving it blank leaves it up to InetAddress.getLocalHost(). This
will always do the Right Thing _if_ the node is properly configured
(hostname, name resolution, etc), and the Right Thing is to use the
address associated with the hostname (it might not be).

Setting listen_address to 0.0.0.0 is always wrong.

Default value 'localhost'

##### `listen_interface`
Setting this to any value effectively means that `listen_address` address
is ignored.
Default value *undef*

##### `manage_dsc_repo`
DEPRECATION WARNING:  This option is deprecated.  Please include the
the ::cassandra::datastax_repo instead.

If set to true then a repository will be setup so that packages can be
downloaded from DataStax community.
Default value 'false'

##### `max_hints_delivery_threads`
Number of threads with which to deliver hints; Consider increasing this number
when you have multi-dc deployments, since cross-dc handoff tends to be slower.
Default value: '2'

##### `max_hint_window_in_ms`
Defines the maximum amount of time a dead host will have hints
generated.  After it has been dead this long, new hints for it will not be
created until it has been seen alive and gone down again.
Default value: '10800000'

##### `memory_allocator`
The off-heap memory allocator.  Affects storage engine metadata as
well as caches.  Experiments show that JEMAlloc saves some memory
than the native GCC allocator (i.e., JEMalloc is more
fragmentation-resistant).

Supported values are:
* NativeAllocator
* JEMallocAllocator

If you intend to use JEMallocAllocator you have to install JEMalloc as library and
modify cassandra-env.sh as directed in the file.

If left as the default, NativeAllocator is assumed.
Default value: *undef*

##### `memtable_cleanup_threshold`
Ratio of occupied non-flushing memtable size to total permitted size
that will trigger a flush of the largest memtable.  Lager mct will
mean larger flushes and hence less compaction, but also less concurrent
flush activity which can make it difficult to keep your disks fed
under heavy write load.

If not set, `memtable_cleanup_threshold` defaults to 1 / (`memtable_flush_writers` + 1)
Default value: *undef*

##### `memtable_flush_writers`
This sets the amount of memtable flush writer threads.  These will
be blocked by disk io, and each one will hold a memtable in memory
while blocked.

If omitted is to set to the smaller of (number of disks,
number of cores), with a minimum of 2 and a maximum of 8.

If your data directories are backed by SSD, you should increase this
to the number of cores.
Default value: *undef*

##### `memtable_heap_space_in_mb`
Total permitted memory to use for memtables. Cassandra will stop
accepting writes when the limit is exceeded until a flush completes,
and will trigger a flush based on `memtable_cleanup_threshold`
If omitted, Cassandra will set both to 1/4 the size of the heap.
Default value: *undef*

##### `memtable_offheap_space_in_mb`
If omitted defaults to 1/4 heap. See `memtable_heap_space_in_mb`.
Default value: *undef*

##### `native_transport_max_concurrent_connections`
The maximum number of concurrent client connections.  The assumed default is -1
when omitted, which means unlimited.
Default value: *undef*

##### `native_transport_max_concurrent_connections_per_ip`
The maximum number of concurrent client connections per source ip.
The assumed default is -1 when omitted, which means unlimited.
Default value: *undef*

##### `native_transport_max_frame_size_in_mb`
The maximum size of allowed frame. Frame (requests) larger than this will
be rejected as invalid.  The assumed default is 256MB when omitted.
Default value: *undef*

##### `native_transport_max_threads`
The maximum threads for handling requests when the native transport is used.
This is similar to `rpc_max_threads` though the default differs slightly (and
there is no native_transport_min_threads, idle threads will always be stopped
after 30 seconds).
Default value: *undef*

##### `native_transport_port`
Port for the CQL native transport to listen for clients on.  For security
reasons, you should not expose this port to the internet.  Firewall it if needed.
Default value '9042'

##### `num_tokens`
This defines the number of tokens randomly assigned to this node on the ring
The more tokens, relative to other nodes, the larger the proportion of data
that this node will store. You probably want all nodes to have the same number
of tokens assuming they have equal hardware capability.

If you leave this unspecified, Cassandra will use the default of 1 token for legacy compatibility,
and will use the `initial_token` as described below.

Specifying `initial_token` will override this setting on the node's initial start,
on subsequent starts, this setting will apply even if initial token is set.

If you already have a cluster with 1 token per node, and wish to migrate to
multiple tokens per node, see http://wiki.apache.org/cassandra/Operations

Default value '256'

##### `package_ensure`
The status of the package specified in **package_name**.  Can be
*present*, *latest* or a specific version number.
Default value 'present'

##### `package_name`
The name of the Cassandra package which must be available from a repository.
Default value **cassandra22** on the Red Hat family of operating systems
or **cassandra** on Debian.

##### `partitioner`
The partitioner is responsible for distributing groups of rows (by
partition key) across nodes in the cluster.  You should leave this
alone for new clusters.  The partitioner can NOT be changed without
reloading all data, so when upgrading you should set this to the
same partitioner you were already using.

Besides Murmur3Partitioner, partitioners included for backwards
compatibility include RandomPartitioner, ByteOrderedPartitioner, and
OrderPreservingPartitioner.

Default value 'org.apache.cassandra.dht.Murmur3Partitioner'

##### `permissions_update_interval_in_ms`
Refresh interval for permissions cache (if enabled).
After this interval, cache entries become eligible for refresh. Upon next
access, an async reload is scheduled and the old value returned until it
completes. If `permissions_validity_in_ms` is non-zero, then this must be
also.
If omitted defaults to the same value as `permissions_validity_in_ms`.
Default value: *undef*

##### `permissions_validity_in_ms`
Validity period for permissions cache (fetching permissions can be an
expensive operation depending on the authorizer, CassandraAuthorizer is
one example). Defaults to 2000, set to 0 to disable.
Will be disabled automatically for AllowAllAuthorizer.
Default value: '2000'

##### `phi_convict_threshold`
Phi value that must be reached for a host to be marked down.
Most users should never need to adjust this.
Default value: *undef*

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

##### `range_request_timeout_in_ms`
How long the coordinator should wait for seq or index scans to complete.
Default value: '10000'

##### `read_request_timeout_in_ms`
How long the coordinator should wait for read operations to complete.
Default value: '5000'

##### `request_scheduler`
Set this to a class that implements RequestScheduler, which will schedule
incoming client requests according to the specific policy. This is useful for
multi-tenancy with a single Cassandra cluster.

NOTE: This is specifically for requests from the client and does not affect
inter node communication.

* org.apache.cassandra.scheduler.NoScheduler - No scheduling takes place
* org.apache.cassandra.scheduler.RoundRobinScheduler - Round robin of
  client requests to a node with a separate queue for each
  request_scheduler_id.

The scheduler is further customized by request_scheduler_options:

* NoScheduler - Has no options
* RoundRobin
  * throttle_limit - The throttle_limit is the number of in-flight requests
  per client.  Requests beyond that limit are queued up until running requests
  can complete.  The value of 80 here is twice the number of
  concurrent_reads + concurrent_writes.
  * default_weight - default_weight is optional and allows for overriding the
  default which is 1.
  * weights - Weights are optional and will default to 1 or the overridden
  default_weight. The weight translates into how many requests are handled
  during each turn of the RoundRobin, based on the scheduler id.

Default value: 'org.apache.cassandra.scheduler.NoScheduler'

##### `request_scheduler_options_default_weight`
See `request_scheduler`.
Default value: *undef*

##### `request_scheduler_options_throttle_limit`
See `request_scheduler`.
Default value: *undef*

##### `request_timeout_in_ms`
How long the coordinator should wait for read operations to complete.
Default value: '10000'

##### `row_cache_keys_to_save`
Number of keys from the row cache to save. Disabled by default, meaning all
keys are going to be saved.
Default value: *undef*

##### `row_cache_save_period`
Duration in seconds after which Cassandra should
save the row cache. Caches are saved to saved_caches_directory as specified
in this configuration file.

Saved caches greatly improve cold-start speeds, and is relatively cheap in
terms of I/O for the key cache. Row cache saving is much more expensive and
has limited use.

Default value: '0' (disable saving the row cache)

##### `row_cache_size_in_mb`
Maximum size of the row cache in memory.

NOTE: if you reduce the size, you may not get you hottest keys loaded on startup.

Default value: '0' (disable row caching)

##### `rpc_address`
The address  bind the Thrift RPC service and native transport server to.

Set rpc_address OR rpc_interface, not both. Interfaces must correspond
to a single address, IP aliasing is not supported.

Leaving rpc_address blank has the same effect as on listen_address
(i.e. it will be based on the configured hostname of the node).

Note that unlike listen_address, you can specify 0.0.0.0, but you must also
set broadcast_rpc_address to a value other than 0.0.0.0.

For security reasons, you should not expose this port to the internet.  Firewall it if needed.

Default value 'localhost'

##### `rpc_interface`
Setting this to any value effectively means that `rpc_address` address
is ignored.
Default value: *undef*

##### `rpc_max_threads`
Set rpc_min|max_thread to set request pool size limits.

Regardless of your choice of RPC server (see `rpc_server_type`), the number of
maximum requests in the RPC thread pool dictates how many concurrent requests
are possible (but if you are using the sync RPC server, it also dictates the
number of clients that can be connected at all).

The default is unlimited and thus provides no protection against clients
overwhelming the server. You are encouraged to set a maximum that makes sense
for you in production, but do keep in mind that rpc_max_threads represents the
maximum number of client requests this server may execute concurrently.
Default value: *undef*

##### `rpc_min_threads`
See `rpc_max_threads`.
Default value: *undef*

##### `rpc_port`
Port for Thrift to listen for clients on.
Default value '9160'

##### `rpc_recv_buff_size_in_bytes`
Change from *undef* to set socket buffer sizes on rpc connections.
Default value: *undef*

##### `rpc_send_buff_size_in_bytes`
Change from *undef* to set socket buffer sizes on rpc connections.
Default value: *undef*

##### `rpc_server_type`
Cassandra provides two out-of-the-box options for the RPC Server:

* sync -> One thread per thrift connection. For a very large number of clients, memory
  will be your limiting factor. On a 64 bit JVM, 180KB is the minimum stack size
  per thread, and that will correspond to your use of virtual memory (but physical memory
  may be limited depending on use of stack space).

* hsha -> Stands for "half synchronous, half asynchronous." All thrift clients are handled
  asynchronously using a small number of threads that does not vary with the amount
  of thrift clients (and thus scales well to many clients). The rpc requests are still
  synchronous (one thread per active request). If hsha is selected then it is essential
  that rpc_max_threads is changed from the default value of unlimited.

The default is sync because on Windows hsha is about 30% slower.  On Linux,
sync/hsha performance is about the same, with hsha of course using less memory.

Alternatively, provide your own RPC server by providing the fully-qualified class name
of an o.a.c.t.TServerFactory that can create an instance of it.

Default value 'sync'

##### `saved_caches_directory`
Default value '/var/lib/cassandra/saved_caches'

See also `commitlog_directory` and `data_file_directories`.

##### `saved_caches_directory_mode`
The mode for the directory specified in `saved_caches_directory`.
Default value '0750'

##### `seeds`
The field being set is `seed_provider -> parameters -> seeds`.

Addresses of hosts that are deemed contact points. Cassandra nodes use this list
of hosts to find each other and learn the topology of the ring. You must change
this if you are running multiple nodes!

seeds is actually a comma-delimited list of addresses. Ex: "ip1,ip2,ip3"

See also `seed_provider_class_name`.

Default value '127.0.0.1'

##### `seed_provider_class_name`
The field being set is `seed_provider -> class_name`.

Any class that implements the SeedProvider interface and has a constructor
that takes a Map(String, String) of parameters will do.

See also `seeds`.

Default value 'org.apache.cassandra.locator.SimpleSeedProvider'

##### `server_encryption_algorithm`
The field being set is `server_encryption_options -> algorithm`.

This is part of the server encryption options.  See also:
`server_encryption_cipher_suites`,
`server_encryption_internode`,
`server_encryption_keystore`,
`server_encryption_keystore_password`,
`server_encryption_protocol`,
`server_encryption_require_client_auth`,
`server_encryption_store_type`,
`server_encryption_truststore`,
`server_encryption_truststore_password`.

Default value: *undef*

##### `server_encryption_cipher_suites`
The field being set is `server_encryption_options -> cipher_suites`.

This is part of the server encryption options.  See also:
`server_encryption_algorithm`,
`server_encryption_cipher_suites`,
`server_encryption_internode`,
`server_encryption_keystore`,
`server_encryption_keystore_password`,
`server_encryption_protocol`,
`server_encryption_require_client_auth`,
`server_encryption_store_type`,
`server_encryption_truststore`,
`server_encryption_truststore_password`.

Default value: *undef*

##### `server_encryption_internode`
The field being set is `server_encryption_options -> internode_encryption`.

This is part of the server encryption options.  See also:
`server_encryption_algorithm`,
`server_encryption_cipher_suites`,
`server_encryption_keystore`,
`server_encryption_keystore_password`,
`server_encryption_protocol`,
`server_encryption_require_client_auth`,
`server_encryption_store_type`,
`server_encryption_truststore`,
`server_encryption_truststore_password`.

Default value 'none'

##### `server_encryption_keystore`
The field being set is `server_encryption_options -> keystore`.

This is part of the server encryption options.  See also:
`server_encryption_algorithm`,
`server_encryption_cipher_suites`,
`server_encryption_internode`,
`server_encryption_keystore_password`,
`server_encryption_protocol`,
`server_encryption_require_client_auth`,
`server_encryption_store_type`,
`server_encryption_truststore`,
`server_encryption_truststore_password`.

Default value 'conf/.keystore'

##### `server_encryption_keystore_password`
The field being set is `server_encryption_options -> keystore_password`.

This is part of the server encryption options.  See also:
`server_encryption_algorithm`,
`server_encryption_cipher_suites`,
`server_encryption_internode`,
`server_encryption_keystore`,
`server_encryption_protocol`,
`server_encryption_require_client_auth`,
`server_encryption_store_type`,
`server_encryption_truststore`,
`server_encryption_truststore_password`.

Default value 'cassandra'

##### `server_encryption_protocol`
The field being set is `server_encryption_options -> protocol`.

This is part of the server encryption options.  See also:
`server_encryption_algorithm`,
`server_encryption_cipher_suites`,
`server_encryption_internode`,
`server_encryption_keystore`,
`server_encryption_keystore_password`,
`server_encryption_require_client_auth`,
`server_encryption_store_type`,
`server_encryption_truststore`,
`server_encryption_truststore_password`.

Default value: *undef*

##### `server_encryption_require_client_auth`
The field being set is `server_encryption_options -> require_client_auth`.

This is part of the server encryption options.  See also:
`server_encryption_algorithm`,
`server_encryption_cipher_suites`,
`server_encryption_internode`,
`server_encryption_keystore`,
`server_encryption_keystore_password`,
`server_encryption_protocol`,
`server_encryption_store_type`,
`server_encryption_truststore`,
`server_encryption_truststore_password`.

Default value: *undef*

##### `server_encryption_store_type`
The field being set is `server_encryption_options -> store_type`.

This is part of the server encryption options.  See also:
`server_encryption_algorithm`,
`server_encryption_cipher_suites`,
`server_encryption_internode`,
`server_encryption_keystore`,
`server_encryption_keystore_password`,
`server_encryption_protocol`,
`server_encryption_require_client_auth`,
`server_encryption_truststore`,
`server_encryption_truststore_password`.

Default value: *undef*

##### `server_encryption_truststore`
The field being set is `server_encryption_options -> truststore`.

This is part of the server encryption options.  See also:
`server_encryption_algorithm`,
`server_encryption_cipher_suites`,
`server_encryption_internode`,
`server_encryption_keystore`,
`server_encryption_keystore_password`,
`server_encryption_protocol`,
`server_encryption_require_client_auth`,
`server_encryption_store_type`,
`server_encryption_truststore_password`.

Default value 'conf/.truststore'

##### `server_encryption_truststore_password`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file.
The field being set is `server_encryption_options -> truststore_password`.

This is part of the server encryption options.  See also:
`server_encryption_algorithm`,
`server_encryption_cipher_suites`,
`server_encryption_internode`,
`server_encryption_keystore`,
`server_encryption_keystore_password`,
`server_encryption_protocol`,
`server_encryption_require_client_auth`,
`server_encryption_store_type`,
`server_encryption_truststore`.

Default value 'cassandra'

##### `service_enable`
Enable the Cassandra service to start at boot time.  Valid values are true
or false.
Default value 'true'

##### `service_ensure`
Ensure the Cassandra service is running.  Valid values are running or stopped.
Default value 'running'

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

##### `service_systemd`
If set to true then a systemd service file called 
${*systemd_path*}/${*service_name*}.service will be added to the node with
basic settings to ensure that the Cassandra service interacts with systemd
better where *systemd_path* will be:

* `/usr/lib/systemd/system` on the Red Hat family.
* `/lib/systemd/system` on Debian the familiy.

Default value false

##### `service_systemd_tmpl`
The location for the template for the systemd service file.  This attribute
only has any effect if `service_systemd` is set to true.

Default value `cassandra/cassandra.service.erb`

##### `snapshot_before_compaction`
Whether or not to take a snapshot before each compaction.  Be
careful using this option, since Cassandra won't clean up the
snapshots for you.  Mostly useful if you're paranoid when there
is a data format change.
Default value 'false'

##### `snitch_properties_file`
The name of the snitch properties file.  The full path name would be
*config_path*/*snitch_properties_file*.
Default value 'cassandra-rackdc.properties'

##### `ssl_storage_port`
SSL port, for encrypted communication.  Unused unless enabled in
encryption_options For security reasons, you should not expose this port to
the internet.  Firewall it if needed.
Default value '7001'

##### `sstable_preemptive_open_interval_in_mb`
When compacting, the replacement sstable(s) can be opened before they
are completely written, and used in place of the prior sstables for
any range that has been written. This helps to smoothly transfer reads 
between the sstables, reducing page cache churn and keeping hot rows hot
Default value: '50'

##### `start_native_transport`
Whether to start the native transport server.
Please note that the address on which the native transport is bound is the
same as the rpc_address. The port however is different and specified below.
Default value 'true'

##### `start_rpc`
Whether to start the thrift rpc server.
Default value 'true'

##### `stream_throughput_outbound_megabits_per_sec`
Throttles all outbound streaming file transfers on a node to the specified
throughput. Cassandra does mostly sequential I/O when streaming data during
bootstrap or repair, which can lead to saturating the network connection and
degrading client (RPC) performance.
Default value: *undef*

##### `storage_port`
TCP port, for commands and data. For security reasons, you should not expose
this port to the internet.  Firewall it if needed.
Default value '7000'

##### `streaming_socket_timeout_in_ms`
Enable socket timeout for streaming operation.
When a timeout occurs during streaming, streaming is retried from the start
of the current file. This _can_ involve re-streaming an important amount of
data, so you should avoid setting the value too low.
If omitted value is 0 is assumed, which never timeout streams.
Default value: *undef*

##### `thrift_framed_transport_size_in_mb`
Frame size for thrift (maximum message length).
Default value: 15

##### `tombstone_failure_threshold`
When executing a scan, within or across a partition, we need to keep the
tombstones seen in memory so we can return them to the coordinator, which
will use them to make sure other replicas also know about the deleted rows.
With workloads that generate a lot of tombstones, this can cause performance
problems and even exaust the server heap.
(http://www.datastax.com/dev/blog/cassandra-anti-patterns-queues-and-queue-like-datasets)
Adjust the thresholds here if you understand the dangers and want to
scan more tombstones anyway.  These thresholds may also be adjusted at runtime
using the StorageService mbean.

See also `tombstone_warn_threshold`.

Default value: '100000'

##### `tombstone_warn_threshold`

See `tombstone_failure_threshold`.

Default value: '1000'

##### `trickle_fsync`
Whether to, when doing sequential writing, fsync() at intervals in
order to force the operating system to flush the dirty
buffers. Enable this to avoid sudden dirty buffer flushing from
impacting read latencies. Almost always a good idea on SSDs; not
necessarily on platters.

See also `trickle_fsync_interval_in_kb`

Default value: 'false'

##### `trickle_fsync_interval_in_kb`
See `trickle_fsync`.
Default value: '10240'

##### `truncate_request_timeout_in_ms`
How long the coordinator should wait for truncates to complete
(This can be much longer, because unless auto_snapshot is disabled
we need to flush first so we can snapshot before removing the data.)
Default value: '60000'

##### `write_request_timeout_in_ms`
How long the coordinator should wait for writes to complete.
Default value: '2000'

### Class: cassandra::datastax_agent

A class for installing the DataStax Agent and to point it at an OpsCenter
instance.

#### Attributes

##### `agent_alias`
If the value is changed from the default of *undef* then this is what is
set as the alias setting in
**/var/lib/datastax-agent/conf/address.yaml**
which is the name the agent announces itself to OpsCenter as.
Default value *undef*

##### `async_pool_size`
If the value is changed from the default of *undef* then this is what is
set as the async_pool_size setting in
**/var/lib/datastax-agent/conf/address.yaml**
which is the pool size to use for async operations to cassandra.
Default value *undef*

##### `async_queue_size`
If the value is changed from the default of *undef* then this is what is
set as the async_queue_size setting in
**/var/lib/datastax-agent/conf/address.yaml**
which is the maximum number of queued cassandra operations.
Default value *undef*

##### `defaults_file`
The full path name to the file where `java_home` is set.
Default value '/etc/default/datastax-agent'

##### `hosts`
If the value is changed from the default of *undef* then this is what is
set as the hosts setting in
**/var/lib/datastax-agent/conf/address.yaml**
which is the DataStax Enterprise node or nodes responsible for storing
OpsCenter data. By default, this will be the local node, but may be
configured to store data on a separate cluster. The hosts option accepts
an array of strings specifying the IP addresses of the node or nodes. For
example, ["1.2.3.4"] or ["1.2.3.4", "1.2.3.5"].
Default value *undef*

##### `java_home`
If the value of this variable is left as *undef*, no action is taken.
Otherwise the value is set as JAVA_HOME in `defaults_file`.
Default value *undef*

##### `local_interface`
If the value is changed from the default of *undef* then this is what is
set as the local_interface setting in
**/var/lib/datastax-agent/conf/address.yaml**
which is the address there the local cassandra will be contacted.
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

##### `service_systemd`
If set to true then a systemd service file called 
${*systemd_path*}/${*service_name*}.service will be added to the node with
basic settings to ensure that the Cassandra service interacts with systemd
better where *systemd_path* will be:

* `/usr/lib/systemd/system` on the Red Hat family.
* `/lib/systemd/system` on Debian the familiy.

Default value false

##### `service_systemd_tmpl`
The location for the template for the systemd service file.  This attribute
only has any effect if `service_systemd` is set to true.

Default value `cassandra/datastax-agent.service.erb`

##### `stomp_interface`
If the value is changed from the default of *undef* then this is what is
set as the stomp_interface setting in
**/var/lib/datastax-agent/conf/address.yaml**
which connects the agent to an OpsCenter instance.
Default value *undef*

##### `storage_keyspace`
If the value is changed from the default of *undef* then this is what is
set as the storage_keyspace setting in
**/var/lib/datastax-agent/conf/address.yaml**
which is keyspace that the agent uses to store data.  See also `hosts`.
Default value *undef*

### Class: cassandra::datastax_repo

An optional class that will allow a suitable repository to be configured
from which packages for DataStax Community can be downloaded.  Changing
the defaults will allow any Debian Apt or Red Hat Yum repository to be
configured.

#### Attributes

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

### Class: cassandra::firewall_ports

An optional class to configure incoming network ports on the host that are
relevant to the Cassandra installation.  If firewalls are being managed
already, simply do not include this module in your manifest.

IMPORTANT: The full list of which ports should be configured is assessed at
evaluation time of the configuration. Therefore if one is to use this class,
it must be the final cassandra class included in the manifest.

#### Attributes

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

##### `inter_node_subnets`
Only has any effect if the `cassandra` class is defined on the node.

An array of the list of subnets that are to allowed connection to
cassandra::storage_port, cassandra::ssl_storage_port and port 7199
for cassandra JMX monitoring.
Default value '['0.0.0.0/0']'

##### `inter_node_ports`
Allow these TCP ports to be opened for traffic
coming from OpsCenter subnets.
Default value '[7000, 7001, 7199]'

##### `public_ports`
Allow these TCP ports to be opened for traffic
coming from public subnets the port specified in `$ssh_port` will be
appended to this list.
Default value '[8888]'

##### `public_subnets`
An array of the list of subnets that are to allowed connection to
cassandra::firewall_ports::ssh_port and if cassandra::opscenter has been
included, both cassandra::opscenter::webserver_port and
cassandra::opscenter::webserver_ssl_port.
Default value '['0.0.0.0/0']'

##### `ssh_port`
Which port does SSH operate on.
Default value '22'

##### `opscenter_ports`
Only has any effect if the `cassandra::datastax_agent` or
`cassandra::opscenter` classes are defined.

Allow these TCP ports to be opened for traffic coming to or from OpsCenter
appended to this list.
Default value [9042, 9160, 61620, 61621]

##### `opscenter_subnets`
A list of subnets that are to be allowed connection to
port 61620 for nodes built with cassandra::opscenter and 61621 for nodes
built with cassandra::datastax_agent.
Default value '['0.0.0.0/0']'

### Class: cassandra::java

A class to install an appropriate Java package.

#### Attributes

##### `ensure`
Is deprecated (see https://github.com/locp/cassandra/wiki/DEP-016).  Use
`package_ensure` instead.

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

### Class: cassandra::opscenter

This class installs and manages the DataStax OpsCenter.  Leaving the defaults
as they are will provide a running OpsCenter without any authentication on
port 8888.

#### Attributes

##### `agents_agent_certfile`
This sets the agent_certfile setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_agent_keyfile`
This sets the agent_keyfile setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_agent_keyfile_raw`
This sets the agent_keyfile_raw setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_config_sleep`
This sets the config_sleep setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_fingerprint_throttle`
This sets the fingerprint_throttle setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_incoming_interface`
This sets the incoming_interface setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_incoming_port`
This sets the incoming_port setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_install_throttle`
This sets the install_throttle setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_not_seen_threshold`
This sets the not_seen_threshold setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_path_to_deb`
This sets the path_to_deb setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_path_to_find_java`
This sets the path_to_find_java setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_path_to_installscript`
This sets the path_to_installscript setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_path_to_rpm`
This sets the path_to_rpm setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_path_to_sudowrap`
This sets the path_to_sudowrap setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_reported_interface`
This sets the reported_interface setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_runs_sudo`
This sets the runs_sudo setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_scp_executable`
This sets the scp_executable setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssh_executable`
This sets the ssh_executable setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssh_keygen_executable`
This sets the ssh_keygen_executable setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssh_keyscan_executable`
This sets the ssh_keyscan_executable setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssh_port`
This sets the ssh_port setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssh_sys_known_hosts_file`
This sets the ssh_sys_known_hosts_file setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssh_user_known_hosts_file`
This sets the ssh_user_known_hosts_file setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssl_certfile`
This sets the ssl_certfile setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_ssl_keyfile`
This sets the ssl_keyfile setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_tmp_dir`
This sets the tmp_dir setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `agents_use_ssl`
This sets the use_ssl setting in the agents section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `authentication_audit_auth`
This sets the audit_auth setting in the authentication section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `authentication_audit_pattern`
This sets the audit_pattern setting in the authentication section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `authentication_method`
This sets the authentication_method setting in the authentication section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `authentication_enabled`
This sets the enabled setting in the authentication section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value 'False'

##### `authentication_passwd_db`
This sets the passwd_db setting in the authentication section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `authentication_timeout`
This sets the timeout setting in the authentication section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `cloud_accepted_certs`
This sets the accepted_certs setting in the cloud section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `clusters_add_cluster_timeout`
This sets the add_cluster_timeout setting in the clusters section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `clusters_startup_sleep`
This sets the startup_sleep setting in the clusters section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `config_file`
The full path to the OpsCenter configuration file.
Default value '/etc/opscenter/opscenterd.conf'

##### `config_purge`
Whether to remove cluster configurations that are not controlled by this puppet module.
Valid values are true or false.
Default value false

##### `definitions_auto_update`
This sets the auto_update setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_definitions_dir`
This sets the definitions_dir setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_download_filename`
This sets the download_filename setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_download_host`
This sets the download_host setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_download_port`
This sets the download_port setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_hash_filename`
This sets the hash_filename setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_sleep`
This sets the sleep setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_ssl_certfile`
This sets the ssl_certfile setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `definitions_use_ssl`
This sets the use_ssl setting in the definitions section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ensure`
Is deprecated (see https://github.com/locp/cassandra/wiki/DEP-016).  Use
`package_ensure` instead.

##### `failover_configuration_directory`
This sets the failover_configuration_directory setting in the failover section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `failover_heartbeat_fail_window`
This sets the heartbeat_fail_window setting in the failover section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `failover_heartbeat_period`
This sets the heartbeat_period setting in the failover section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `failover_heartbeat_reply_period`
This sets the heartbeat_reply_period setting in the failover section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `hadoop_base_job_tracker_proxy_port`
This sets the base_job_tracker_proxy_port setting in the hadoop section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `orbited_longpoll`
This sets the orbited_longpoll setting in the labs section of the OpsCenter 
configuration file. See labs http://docs.datastax.com/en/opscenter/5.2/opsc/troubleshooting/opscTroubleshootingZeroNodes.html
for more details.  A value of *undef* will ensure the setting is not present in 
the file. Default value *undef*

##### `ldap_admin_group_name`
This sets the admin_group_name setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_connection_timeout`
This sets the connection_timeout setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_debug_ssl`
This sets the debug_ssl setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_group_name_attribute`
This sets the group_name_attribute setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_group_search_base`
This sets the group_search_base setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_group_search_filter`
Is deprecated use `ldap_group_search_filter_with_dn` instead.

This sets the group_search_filter setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_group_search_filter_with_dn`
This sets the group_search_filter_with_dn setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_group_search_type`
This sets the group_search_type setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_ldap_security`
This sets the ldap_security setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_opt_referrals`
This sets the opt_referrals setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_protocol_version`
This sets the protocol_version setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_search_dn`
This sets the search_dn setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_search_password`
This sets the search_password setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_server_host`
This sets the server_host setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_server_port`
This sets the server_port setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_ssl_cacert`
This sets the ssl_cacert setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_ssl_cert`
This sets the ssl_cert setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_ssl_key`
This sets the ssl_key setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_tls_demand`
This sets the tls_demand setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_tls_reqcert`
This sets the tls_reqcert setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_uri_scheme`
This sets the uri_scheme setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_user_memberof_attribute`
This sets the user_memberof_attribute setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_user_search_base`
This sets the user_search_base setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ldap_user_search_filter`
This sets the user_search_filter setting in the ldap section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `logging_level`
This sets the level setting in the logging section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `logging_log_length`
This sets the log_length setting in the logging section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `logging_log_path`
This sets the log_path setting in the logging section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `logging_max_rotate`
This sets the max_rotate setting in the logging section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `logging_resource_usage_interval`
This sets the resource_usage_interval setting in the logging section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `package_ensure`
This is passed to the package reference for **opscenter**.  Valid values are
**present** or a version number.
Default value 'present'

##### `package_name`
The name of the OpsCenter package.
Default value 'opscenter'

##### `provisioning_agent_install_timeout`
This sets the agent_install_timeout setting in the provisioning section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `provisioning_keyspace_timeout`
This sets the keyspace_timeout setting in the provisioning section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `provisioning_private_key_dir`
This sets the private_key_dir setting in the provisioning section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_alert_on_repair_failure`
This sets the alert_on_repair_failure setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_cluster_stabilization_period`
This sets the cluster_stabilization_period setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_error_logging_window`
This sets the error_logging_window setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_incremental_err_alert_threshold`
This sets the incremental_err_alert_threshold setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_incremental_range_repair`
This sets the incremental_range_repair setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_incremental_repair_tables`
This sets the incremental_repair_tables setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_ks_update_period`
This sets the ks_update_period setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_log_directory`
This sets the log_directory setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_log_length`
This sets the log_length setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_max_err_threshold`
This sets the max_err_threshold setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_max_parallel_repairs`
This sets the max_parallel_repairs setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_max_pending_repairs`
This sets the max_pending_repairs setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_max_rotate`
This sets the max_rotate setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_min_repair_time`
This sets the min_repair_time setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_min_throughput`
This sets the min_throughput setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_num_recent_throughputs`
This sets the num_recent_throughputs setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_persist_directory`
This sets the persist_directory setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_persist_period`
This sets the persist_period setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_restart_period`
This sets the restart_period setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_single_repair_timeout`
This sets the single_repair_timeout setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_single_task_err_threshold`
This sets the single_task_err_threshold setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `repair_service_snapshot_override`
This sets the snapshot_override setting in the repair_service section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `request_tracker_queue_size`
This sets the queue_size setting in the request_tracker section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `security_config_encryption_active`
This sets the config_encryption_active setting in the security section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `security_config_encryption_key_name`
This sets the config_encryption_key_name setting in the security section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `security_config_encryption_key_path`
This sets the config_encryption_key_path setting in the security section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `service_enable`
Enable the OpsCenter service to start at boot time.  Valid values are true
or false.
Default value 'true'

##### `service_ensure`
Ensure the OpsCenter service is running.  Valid values are running or stopped.
Default value 'running'

##### `service_name`
The name of the service that runs the OpsCenter software.
Default value 'opscenterd'

##### `service_provider`
The name of the provider that runs the service.  If left as *undef* then the OS family specific default will
be used, otherwise the specified value will be used instead.
Default value *undef*

##### `service_systemd`
If set to true then a systemd service file called 
${*systemd_path*}/${*service_name*}.service will be added to the node with
basic settings to ensure that the Cassandra service interacts with systemd
better where *systemd_path* will be:

* `/usr/lib/systemd/system` on the Red Hat family.
* `/lib/systemd/system` on Debian the familiy.

Default value false

##### `service_systemd_tmpl`
The location for the template for the systemd service file.  This attribute
only has any effect if `service_systemd` is set to true.

Default value `cassandra/opscenterd.service.erb`

##### `spark_base_master_proxy_port`
This sets the base_master_proxy_port setting in the spark section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `stat_reporter_initial_sleep`
This sets the initial_sleep setting in the stat_reporter section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `stat_reporter_interval`
This sets the interval setting in the stat_reporter section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `stat_reporter_report_file`
This sets the report_file setting in the stat_reporter section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `stat_reporter_ssl_key`
This sets the ssl_key setting in the stat_reporter section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ui_default_api_timeout`
This sets the default_api_timeout setting in the ui section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ui_max_metrics_requests`
This sets the max_metrics_requests setting in the ui section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ui_node_detail_refresh_delay`
This sets the node_detail_refresh_delay setting in the ui section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `ui_storagemap_ttl`
This sets the storagemap_ttl setting in the ui section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `webserver_interface`
This sets the interface setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value '0.0.0.0'

##### `webserver_log_path`
This sets the log_path setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `webserver_port`
This sets the port setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value '8888'

##### `webserver_ssl_certfile`
This sets the ssl_certfile setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `webserver_ssl_keyfile`
This sets the ssl_keyfile setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `webserver_ssl_port`
This sets the ssl_port setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `webserver_staticdir`
This sets the staticdir setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `webserver_sub_process_timeout`
This sets the sub_process_timeout setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*

##### `webserver_tarball_process_timeout`
This sets the tarball_process_timeout setting in the webserver section of the
OpsCenter configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for more details.  A value of *undef* will ensure the setting is not present
in the file.  Default value *undef*


### Class: cassandra::opscenter::pycrypto

On the Red Hat family of operating systems, if one intends to use encryption
for configuration values then the pycrypto library is required.  This class
will install it for the user.  See
http://docs.datastax.com/en/opscenter/5.2//opsc/configure/installPycrypto.html
for more details.

This class has no effect when included on nodes that are not in the Red Hat
family.

#### Attributes

##### `ensure`
Is deprecated (see https://github.com/locp/cassandra/wiki/DEP-016).  Use
`package_ensure` instead.

##### `manage_epel`
If set to true, the **epel-release** package will be installed.
Default value 'false'

##### `package_ensure`
This is passed to the package reference for **pycrypto**.  Valid values are
**present** or a version number.
Default value 'present'

##### `package_name`
The name of the PyCrypto package.
Default value 'pycrypto'

##### `provider`
The name of the provider of the pycrypto package.
Default value 'pip'

##### `reqd_pckgs`
Packages that are required to install the pycrypto package.
Default value '['python-devel', 'python-pip' ]'

### Class: cassandra::optutils

A class to install the optional Cassandra tools package.

#### Attributes

##### `ensure`
Is deprecated (see https://github.com/locp/cassandra/wiki/DEP-016).  Use
`package_ensure` instead.

##### `package_ensure`
The status of the package specified in **package_name**.  Can be
*present*, *latest* or a specific version number.
Default value 'present'

##### `package_name`
If the default value of *undef* is left as it is, then a package called
cassandra22-tools or cassandra-tools will be installed
on a Red Hat family or Debian system respectively.  Alternatively, one
can specify a package that is available in a package repository to the
node.
Default value *undef*

### Class: cassandra::schema

A class to maintain the database schema.  Please note that cqlsh expects
Python 2.7 to be installed.  This may be a problem of older distributions
(CentOS 6 for example).

#### Attributes

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

##### `cqlsh_command`
The full path to the **cqlsh** command.

Default value '/usr/bin/cqlsh'

##### `cqlsh_host`
The host for the **cqlsh** command to connect to.  See also `cqlsh_port`.

Default value `$::cassandra::listen_address`

##### `cqlsh_password`
If credentials are require for connecting, specify the password here.
See also `cqlsh_user`.

Default value *undef*

##### `cqlsh_port`
The host for the **cqlsh** command to connect to.  See also `cqlsh_host`.
See also `cqlsh_host`.

Default value `$::cassandra::native_transport_port`

##### `cqlsh_user`
If credentials are require for connecting, specify the password here.
See also `cqlsh_password`.

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

### Defined Type cassandra::opscenter::cluster_name

With DataStax Enterprise, one can specify a remote keyspace for OpsCenter
to store metric data (this is not available in the DataStax Community Edition).

#### Attributes

##### `cassandra_seed_hosts`
This sets the seed_hosts setting in the cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `config_path`
The path to where OpsCenter stores the cluster configurations.
Default value '/etc/opscenter/clusters'

##### `storage_cassandra_api_port`
This sets the api_port setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_bind_interface`
This sets the bind_interface setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_connection_pool_size`
This sets the connection_pool_size setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_connect_timeout`
This sets the connect_timeout setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_cql_port`
This sets the cql_port setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_keyspace`
This sets the keyspace setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_local_dc_pref`
This sets the local_dc_pref setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_password`
This sets the password setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_retry_delay`
This sets the retry_delay setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_seed_hosts`
This sets the seed_hosts setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_send_rpc`
This sets the send_rpc setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_ssl_ca_certs`
This sets the ssl_ca_certs setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_ssl_client_key`
This sets the ssl_client_key setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_ssl_client_pem`
This sets the ssl_client_pem setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_ssl_validate`
This sets the ssl_validate setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_used_hosts_per_remote_dc`
This sets the used_hosts_per_remote_dc setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

##### `storage_cassandra_username`
This sets the username setting in the storage_cassandra section of the
_cluster_name_.conf configuration file.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscStoringCollectionDataDifferentCluster_t.html
for more details.  A value of *undef* will ensure the setting is not
present in the file.  Default value *undef*

### Defined Type cassandra::schema::cql_type

Create or drop user defined data types within the schema.  Please see the
example code in the [Schema Maintenance](#schema-maintenance) and the
[Limitations - OS compatibility, etc.](#limitations) sections of this document.

#### Attributes

##### `keyspace`
The name of the keyspace that the data type is to be associated with.

##### `ensure`
Valid values can be **present** to ensure a data type is created, or
**absent** to ensure it is dropped.

##### `fields`
A hash of the fields that will be components for the data type.  See
the example earlier in this document for the layout of the hash.

### Defined Type cassandra::schema::index

Create or drop indexes within the schema.  Please see the
example code in the [Schema Maintenance](#schema-maintenance) and the
[Limitations - OS compatibility, etc.](#limitations) sections of this document.

#### Attributes

##### `class_name`
The name of the class to be associated with a class when creating
a custom class.

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

### Defined Type cassandra::schema::keyspace

Create or drop keyspaces within the schema.  Please see the example code in the
[Schema Maintenance](#schema-maintenance) and the
[Limitations - OS compatibility, etc.](#limitations) sections of this document.

#### Attributes

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

##### `ensure`
Valid values can be **present** to ensure a keyspace is created, or
**absent** to ensure it is dropped.

### Defined Type cassandra::schema::table

Create or drop tables within the schema.  Please see the example code in the
[Schema Maintenance](#schema-maintenance) and the
[Limitations - OS compatibility, etc.](#limitations) sections of this document.

#### Attributes

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

### Defined Type cassandra::private::data_directory

A defined type to handle the `::cassandra::data_file_directoryies` array.
This is not intended to be used by a user but is documented here for
completeness.

#### Attributes

##### `title`
The name of an individual directory.

### Defined Type cassandra::private::firewall_ports::rule

A defined type to be used as a macro for setting host based firewall
rules.  This is not intended to be used by a user (who should use the
API provided by cassandra::firewall_ports instead) but is documented
here for completeness.

#### Attributes

##### `title`
A text field that contains the protocol name and CIDR address of a subnet.

##### `port`
The number(s) of the port(s) to be opened.

### Defined Type cassandra::private::opscenter::setting

A defined type to be used as a macro for settings in the OpsCenter
configuration file.  This is not intended to be used by a user (who
should use the API provided by cassandra::opscenter instead) but is documented
here for completeness.

#### Attributes

##### `service_name`
The name of the service to be notified if a change is made to the
configuration file.  Typically this would by **opscenterd**.

##### `path`
The path to the configuration file.  Typically this would by
**/etc/opscenter/opscenterd.conf**.

##### `section`
The section in the configuration file to be added to (e.g. **webserver**).

##### `setting`
The setting within the section of the configuration file to changed
(e.g. **port**).

##### `value`
The setting value to be changed to (e.g. **8888**).

## Limitations

Tested on the Red Hat family versions 6 and 7, Ubuntu 12.04 and 14.04,
Debian 7 Puppet (CE) 3.7.5 and DSC 2.  Currently this module does not support
Cassandra 3 but this is planned for the near future.

From release 1.6.0 of this module, regular updates of the Cassandra 1.X
template will cease and testing against this template will cease.  Testing
against the template for versions of Cassandra >= 2.X will continue.

When creating key spaces, the settings will only be used to create a new
key space if it does not currently exist.  If a change is made to the
Puppet manifest but the key space already exits, this change will not
be reflected.

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
0.3.0        | [#11](https://github.com/locp/cassandra/pull/11)    | [@spredzy](https://github.com/Spredzy)
0.4.2        | [#34](https://github.com/locp/cassandra/pull/34)    | [@amosshapira](https://github.com/amosshapira)
1.3.3        | [#87](https://github.com/locp/cassandra/pull/87)    | [@DylanGriffith](https://github.com/DylanGriffith)
1.3.5        | [#93](https://github.com/locp/cassandra/issues/93)  | [@sampowers](https://github.com/sampowers)
1.4.0        | [#100](https://github.com/locp/cassandra/pull/100)  | [@markasammut](https://github.com/markasammut)
1.4.2        | [#110](https://github.com/locp/cassandra/pull/110)  | [@markasammut](https://github.com/markasammut)
1.9.2        | [#136](https://github.com/locp/cassandra/issues/136)| [@mantunovic](https://github.com/mantunovic)
1.9.2        | [#136](https://github.com/locp/cassandra/issues/136)| [@al4](https://github.com/al4)
1.10.0       | [#144](https://github.com/locp/cassandra/pull/144)  | [@Mike-Petersen](https://github.com/Mike-Petersen)
1.12.0       | [#153](https://github.com/locp/cassandra/pull/153)  | [@Mike-Petersen](https://github.com/Mike-Petersen)
1.12.0       | [#156](https://github.com/locp/cassandra/pull/156)  | [@stuartbfox](https://github.com/stuartbfox)
1.12.2       | [#165](https://github.com/locp/cassandra/pull/165)  | [@palmertime](https://github.com/palmertime)
1.13.0       | [#163](https://github.com/locp/cassandra/pull/163)  | [@VeriskPuppet](https://github.com/VeriskPuppet)
1.13.0       | [#166](https://github.com/locp/cassandra/pull/166)  | [@Mike-Petersen](https://github.com/Mike-Petersen)
1.14.0       | [#171](https://github.com/locp/cassandra/pull/171)  | [@jonen10](https://github.com/jonen10)
1.15.0       | [#189](https://github.com/locp/cassandra/pull/189)  | [@tibers](https://github.com/tibers)
1.18.0       | [#203](https://github.com/locp/cassandra/pull/203)  | [@Mike-Petersen](https://github.com/Mike-Petersen)
