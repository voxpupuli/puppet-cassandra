# Contributing

Contributions will be gratefully accepted. Please go to the project page, fork
the project, make your changes locally and then raise a pull request. Details
on how to do this are available at
https://guides.github.com/activities/contributing-to-open-source.

However, we do ask that:

* All unit tests pass correctly.  For details on running unit tests, see below.
  Also all pull requests have the unit tests run against them on CircleCI (see
  https://circleci.com/gh/locp/cassandra).
* Any attributes are documented.  This should be done in the README file in
  the section for the specific class.  Class attributes are listed, both in
  the manifest code and the README alphabetically.

If your initial unit tests fail after a pull request and you need to fix them,
simply change the code on your branch and push them to *origin* again as this
will re-run the tests.  It is not required to submit a new pull request.

If you don't know how to fix the failing tests, simply ask for help in the
pull request and we'll do our best to help.

## Testing

### Spec Tests (Unit Testing)

At the very least, before submitting your pull request or patch, the following
tests should pass with no errors or warnings:

```bash
bundle update             # Update/install your bundle
bundle exec rake lint     # Run puppet-lint
bundle exec rake validate # Check syntax of Ruby files and call :syntax and :metadata
bundle exec rake spec     # Run spec tests in a clean fixtures directory
```

### Beaker Tests (Acceptance Testing)

These tests are more expensive and are normally only ran in preparation for
a release.  More details are available at
https://github.com/locp/cassandra/wiki/Acceptance-(Beaker)-Tests
which describes the transition of the test harness from Vagrant to Docker.

```bash
for node in $( bundle exec rake beaker_nodes ); do
  export BEAKER_set=$node
  BEAKER_destroy=onpass bundle exec rake beaker || break
done
```

### Further Reading

* *RSpec tests for your Puppet manifests* <http://rspec-puppet.com/>
* *Beaker Info* <https://github.com/puppetlabs/beaker/tree/master/docs>
