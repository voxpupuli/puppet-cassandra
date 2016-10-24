# Contributing to the Module or Raising Issues

## Table of Contents

1. [Raising an Issue](#raising-an-issue)
1. [Contribtions](#contributions)
  * [Unit Tests](#unit-tests)
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

## Further Reading

* *RSpec tests for your Puppet manifests* <http://rspec-puppet.com/>
* *Beaker Info* <https://github.com/puppetlabs/beaker/tree/master/docs>
