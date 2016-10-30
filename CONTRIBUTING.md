# Contributing to the Module or Raising Issues

## Table of Contents

1. [Raising an Issue](#raising-an-issue)
1. [Contribtions](#contributions)
  * [Unit Tests](#unit-tests)
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

## Contributors

**Release**  | **PR/Issue**                                        | **Contributer**
-------------|-----------------------------------------------------|----------------------------------------------------
2.0.2       | [#291](https://github.com/locp/cassandra/issues/291)| [@ericy-jana](https://github.com/ericy-jana)
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

## Further Reading

* *RSpec tests for your Puppet manifests* <http://rspec-puppet.com/>
* *Beaker Info* <https://github.com/puppetlabs/beaker/tree/master/docs>
