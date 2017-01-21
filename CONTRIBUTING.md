# Contributing to the Module or Raising Issues

## Table of Contents

1. [Raising an Issue](#raising-an-issue)
1. [Contribtions](#contributions)
  * [Unit Tests](#unit-tests)
  * [Acceptance Tests](#acceptance-tests)
1. [Contributors](#contributors)
1. [Further Reading](#further-reading)

## Raising an Issue

When raising an issue, please provide the following information:

* The version of the locp-cassandra module that you are using.
* The version of Cassandra that you are installing.
* The operating system and release (output from `facter os` would be
  appropriate).
* A sample of your manifest/profile that is calling the `cassandra` module.
  Feel free to obfuscate sections of the code that contain details that
  are confidential (e.g. passwords and other secrets).

## Contributions

Contributions will be gratefully accepted. Please go to the project page, fork
the project, make your changes locally and then raise a pull request. Details
on how to do this are available at
https://guides.github.com/activities/contributing-to-open-source.

However, we do ask that at the very least, all items marked as **MUST** or
**WON'T** in the list below are applicable:

* Any new features (e.g. new resources or new attributes to existing resoures)
  **MUST** be fully documented .
* Unit tests **MUST** be completing successfully.  See
  [Unit Tests](#unit-tests) for more details.  If your initial unit tests fail
  after a pull request and you need to fix them, simply change the code on
  your branch and push them to *origin* again as this will re-run the
  tests.  It is not required to submit a new pull request.
* Any new functionality or enhancements **SHOULD** be covered by unit/spec
  tests.  If you are not comfortable with this, submit the PR anyway and
  we will fill in these gaps.  You will most probably be asked to rebase
  your PR branch and then push again to register these changes.
* If applicable, changes **COULD** be covered in beaker/acceptance tests.
* Change **WON'T** break any functionality on any of the supported operating
  systems.

### Unit Tests

First, you'll need to install the testing dependencies using
[bundler](http://bundler.io).

```shell
bundle install
```

To run all of the unit tests execute the following:

```shell
bundle exec rake test
```

This should output something like the following:

```
Running RuboCop...
Inspecting 24 files
........................

24 files inspected, no offenses detected
---> syntax:manifests
---> syntax:templates
---> syntax:hiera:yaml
/home/ben/.rvm/rubies/ruby-2.1.6/bin/ruby -I/home/ben/.rvm/gems/ruby-2.1.6/gems/rspec-core-3.5.4/lib:/home/ben/.rvm/gems/ruby-2.1.6/gems/rspec-support-3.5.0/lib /home/ben/.rvm/gems/ruby-2.1.6/gems/rspec-core-3.5.4/exe/rspec --pattern spec/\{aliases,classes,defines,unit,functions,hosts,integration,types\}/\*\*/\*_spec.rb --color
[Coveralls] Set up the SimpleCov formatter.
[Coveralls] Using SimpleCov's default settings.
.......................................................

Finished in 7.86 seconds (files took 0.81841 seconds to load)
55 examples, 0 failures


Total resources:   64
Touched resources: 64
Resource coverage: 100.00%
[Coveralls] Outside the CI environment, not sending data.
```

Note that if you prefer, you can run the lint, syntax, and spec tests separately with individual commands:

```shell
bundle exec rake metadata_lint
bundle exec rake rubocop
bundle exec rake lint
bundle exec rake validate
bundle exec rake spec
```

If in doubt, or you are stuck, please ask for help in the PR or via our
[Gitter Room](https://gitter.im/locp/cassandra).

The unit tests will also fail if the test coverage falls below 100%.

### Acceptance Tests

These tests are more CPU intensive and are run via Docker.  You will
need to install further gems for this to work with the following
command:

```shell
bundle install --with acceptance
```

Then run the tests:

```shell
bundle exec rake beaker:centos6
bundle exec rake beaker:centos7                                        
bundle exec rake beaker:debian7                                        
bundle exec rake beaker:debian8                                        
bundle exec rake beaker:ubuntu1204                                     
bundle exec rake beaker:ubuntu1404                                     
bundle exec rake beaker:ubuntu1604                                     
```

## Contributors

**Release** | **PR/Issue**                                        | **Contributer**
------------|-----------------------------------------------------|----------------------------------------------------
2.3.0       | [Hiera documentation](https://github.com/locp/cassandra/pull/329)  | [@tibers](https://github.com/tibers)
2.1.1       | [Correct cql_types conditional in cassandra::schema class](https://github.com/locp/cassandra/pull/325)| [@aaron-miller](https://github.com/aaron-miller)
2.0.2       | [locp/cassandra 2.0 example has two cassandra declarations](https://github.com/locp/cassandra/issues/291)| [@ericy-jana](https://github.com/ericy-jana)
2.0.0       | [Convert cassandra::file from a class to a define](https://github.com/locp/cassandra/issues/266)| [@stanleyz](https://github.com/stanleyz)
1.26.1      | [Correct cql_types conditional in cassandra::schema class](https://github.com/locp/cassandra/pull/325)| [@aaron-miller](https://github.com/aaron-miller)
1.25.2      | [Ubuntu 16 doesnt like the service file](https://github.com/locp/cassandra/issues/269)| [@ahharu](https://github.com/ahharu)
1.25.1      | [PID file name in systemd file for datastax-agent doesn't match PID file name in /etc/init.d/datastax-agent](https://github.com/locp/cassandra/issues/264)| [@pampelix](https://github.com/pampelix)
1.25.0      | [adding support for mmap](https://github.com/locp/cassandra/pull/261)  | [@tibers](https://github.com/tibers)
1.24.0      | [remove varlib_dir require from data directory](https://github.com/locp/cassandra/pull/247)  | [@ericy-jana](https://github.com/ericy-jana)
1.24.0      | [stage config files before installing cassandra package](https://github.com/locp/cassandra/pull/246)  | [@ericy-jana](https://github.com/ericy-jana)
1.24.0      | [locp/cassandra starts two Cassandra processes](https://github.com/locp/cassandra/issues/245)| [@ericy-jana](https://github.com/ericy-jana)
1.23.0      | [attemping to realize client security](https://github.com/locp/cassandra/pull/235)  | [@tibers](https://github.com/tibers)
1.22.1      | [#232 - add ordering to service definition](https://github.com/locp/cassandra/pull/233)  | [@tibers](https://github.com/tibers)
1.22.1      | [module tries to start cassandra before it's installed](https://github.com/locp/cassandra/issues/232)| [@tibers](https://github.com/tibers)
1.21.0      | [Issue: Java version installed on Debian family by cassandra::java class #223](https://github.com/locp/cassandra/pull/226)  | [@tibers](https://github.com/tibers)
1.20.0      | [Missing attributes in cassandra.yaml](https://github.com/locp/cassandra/issues/217)| [@samyray](https://github.com/samyray)
1.19.0      | [adding hints_directory for cassandra 3.x](https://github.com/locp/cassandra/pull/215)  | [@tibers](https://github.com/tibers)
1.18.0      | [Added opscenter ldap option group_search_filter_with_dn](https://github.com/locp/cassandra/pull/203)  | [@Mike-Petersen](https://github.com/Mike-Petersen)
1.15.0      | [creating vanilla cassandra 2.0.xx template](https://github.com/locp/cassandra/pull/189)  | [@tibers](https://github.com/tibers)
1.14.0      | [Feature/opscenter orbited longpoll](https://github.com/locp/cassandra/pull/171)  | [@jonen10](https://github.com/jonen10)
1.13.0      | [Allowing setting of async_pool_size and async_queue_size for the agent](https://github.com/locp/cassandra/pull/166)  | [@Mike-Petersen](https://github.com/Mike-Petersen)
1.13.0      | [parameterized thrift_framed_transport_size_in_mb](https://github.com/locp/cassandra/pull/163)  | [@VeriskPuppet](https://github.com/VeriskPuppet)
1.12.2      | [Error opening zip file or JAR manifest missing : /usr/sbin/../lib/jamm-0.3.0.jar](https://github.com/locp/cassandra/pull/165)  | [@palmertime](https://github.com/palmertime)
1.12.0      | [Rename alias to agent_alias as alias is a reserved puppet word](https://github.com/locp/cassandra/pull/156)  | [@stuartbfox](https://github.com/stuartbfox)
1.12.0      | [Added interfaces as an option](https://github.com/locp/cassandra/pull/153)  | [@Mike-Petersen](https://github.com/Mike-Petersen)
1.10.0      | [Allowing setting of local_interface for the datastax agent configuration](https://github.com/locp/cassandra/pull/144)  | [@Mike-Petersen](https://github.com/Mike-Petersen)
1.9.2       | [When installing cassandra dsc22 it tries to install cassandra 3.0.0 and as dependecy 2.2.3 is needed](https://github.com/locp/cassandra/issues/136)| [@mantunovic](https://github.com/mantunovic)
1.9.2       | [When installing cassandra dsc22 it tries to install cassandra 3.0.0 and as dependecy 2.2.3 is needed](https://github.com/locp/cassandra/issues/136)| [@al4](https://github.com/al4)
1.4.2       | [restart service if datastax agent package is upgraded](https://github.com/locp/cassandra/pull/110)  | [@markasammut](https://github.com/markasammut)
1.4.0       | [allow batch_size_warn_threshold to be modified externally](https://github.com/locp/cassandra/pull/100)  | [@markasammut](https://github.com/markasammut)
1.3.5       | [service_ensure unused](https://github.com/locp/cassandra/issues/93)  | [@sampowers](https://github.com/sampowers)
1.3.3       | [Fails To Run With puppetlabs-apt v1.8.0](https://github.com/locp/cassandra/pull/87)    | [@DylanGriffith](https://github.com/DylanGriffith)
0.4.2       | [Fix syntax in version_requirements](https://github.com/locp/cassandra/pull/34)    | [@amosshapira](https://github.com/amosshapira)
0.3.0       | [Add a template for Cassandra 1.x compat](https://github.com/locp/cassandra/pull/11)    | [@spredzy](https://github.com/Spredzy)

## Further Reading

* *RSpec tests for your Puppet manifests* <http://rspec-puppet.com/>
* *Beaker Info* <https://github.com/puppetlabs/beaker/tree/master/docs>
