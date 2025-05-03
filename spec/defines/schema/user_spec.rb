# frozen_string_literal: true

require 'spec_helper'

describe 'cassandra::schema::user' do
  let(:node) { 'foo.example.com' }

  # Title is essential to set the username.
  let(:title) { 'bob' }

  # As much as possible, parameters have been left default.
  # This will serve as a massive red flag should defaults unexpectedly change.
  # In the past parameters were often overriden, which both duplicated the default values
  # and would prevent detection of an accidental change from default values.
  let(:params) do
    {
      'password' => 'Niner2',
    }
  end
  let(:pre_condition) { 'include cassandra::params' }

  on_supported_os.each do |_os, os_facts|
    context 'when cassandrarelease is undef' do
      let(:facts) { os_facts }

      context 'with use_scl => false' do
        context 'with superuser => true' do
          let(:params) do
            super().merge({
                            'superuser' => true
                          })
          end

          it 'creates a super user' do
            expect(subject).to contain_cassandra__schema__user('bob').with_ensure('present')
            read_command = '/usr/bin/cqlsh   -e "LIST USERS" localhost 9042 | grep \'\s*bob |\''
            exec_command =  '/usr/bin/cqlsh   -e "CREATE USER IF NOT EXISTS bob'
            exec_command += ' WITH PASSWORD \'Niner2\' SUPERUSER" localhost 9042'
            expect(subject).to contain_exec('Create user (bob)').
              only_with(command: exec_command,
                        unless: read_command,
                        require: 'Exec[cassandra::schema connection test]')
          end
        end
      end

      context 'with use_scl => true' do
        let(:params) do
          super().merge({
                          'use_scl' => true,
                          'scl_name' => 'testscl',
                        })
        end

        context 'with superuser' do
          let(:params) do
            super().merge({
                            'superuser' => true
                          })
          end

          it 'creates a super user' do
            expect(subject).to contain_cassandra__schema__user('bob').with_ensure('present')
            read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST USERS\" localhost 9042 | grep \'\s*bob |\'"'
            exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE USER IF NOT EXISTS bob'
            exec_command += ' WITH PASSWORD \'Niner2\' SUPERUSER\" localhost 9042"'
            expect(subject).to contain_exec('Create user (bob)').
              only_with(command: exec_command,
                        unless: read_command,
                        require: 'Exec[cassandra::schema connection test]')
          end
        end
      end
    end

    context 'when cassandrarelease > 2.2' do
      let :facts do
        os_facts.merge({
                         cassandrarelease: '4.0.0',
                       })
      end

      context 'with use_scl => false' do
        context 'with superuser => true' do
          let(:params) do
            super().merge({ 'superuser' => true })
          end

          it 'create superuser' do
            expect(subject).to contain_cassandra__schema__user('bob').with_ensure('present')
            read_command = '/usr/bin/cqlsh   -e "LIST ROLES" localhost 9042 | grep \'\s*bob |\''
            exec_command =  '/usr/bin/cqlsh   -e "CREATE ROLE IF NOT EXISTS bob'
            exec_command += ' WITH PASSWORD = \'Niner2\' AND SUPERUSER = true AND LOGIN = true" localhost 9042'
            expect(subject).to contain_exec('Create user (bob)').
              only_with(command: exec_command,
                        unless: read_command,
                        require: 'Exec[cassandra::schema connection test]')
          end
        end

        context 'with login => false' do
          let(:params) do
            super().merge({ 'login' => false })
          end

          it 'creates user without login' do
            expect(subject).to contain_cassandra__schema__user('bob').with_ensure('present')
            read_command = '/usr/bin/cqlsh   -e "LIST ROLES" localhost 9042 | grep \'\s*bob |\''
            exec_command =  '/usr/bin/cqlsh   -e "CREATE ROLE IF NOT EXISTS bob'
            exec_command += ' WITH PASSWORD = \'Niner2\'" localhost 9042'
            expect(subject).to contain_exec('Create user (bob)').
              only_with(command: exec_command,
                        unless: read_command,
                        require: 'Exec[cassandra::schema connection test]')
          end
        end

        context 'with ensure => absent' do
          let(:params) do
            super().merge({ 'ensure' => 'absent' })
          end

          it 'drops a user' do
            read_command = '/usr/bin/cqlsh   -e "LIST ROLES" localhost 9042 | grep \'\s*bob |\''
            exec_command = '/usr/bin/cqlsh   -e "DROP ROLE bob" localhost 9042'
            expect(subject).to contain_exec('Delete user (bob)').
              only_with(command: exec_command,
                        onlyif: read_command,
                        require: 'Exec[cassandra::schema connection test]')
          end
        end
      end

      context 'with use_scl => true' do
        let(:params) do
          super().merge({
                          'use_scl' => true,
                          'scl_name' => 'testscl',
                        })
        end

        context 'with superuser => true' do
          let(:params) do
            super().merge({ 'superuser' => 'true' })
          end

          it 'creates a superuser' do
            expect(subject).to contain_cassandra__schema__user('bob').with_ensure('present')
            read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST ROLES\" localhost 9042 | grep \'\s*bob |\'"'
            exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE ROLE IF NOT EXISTS bob'
            exec_command += ' WITH PASSWORD = \'Niner2\' AND SUPERUSER = true AND LOGIN = true\" localhost 9042"'
            expect(subject).to contain_exec('Create user (bob)').
              only_with(command: exec_command,
                        unless: read_command,
                        require: 'Exec[cassandra::schema connection test]')
          end
        end

        context 'with login => false' do
          let(:params) do
            super().merge({ 'login' => false })
          end

          it 'creates a user without login' do
            expect(subject).to contain_cassandra__schema__user('bob').with_ensure('present')
            read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST ROLES\" localhost 9042 | grep \'\s*bob |\'"'
            exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE ROLE IF NOT EXISTS bob'
            exec_command += ' WITH PASSWORD = \'Niner2\'\" localhost 9042"'
            expect(subject).to contain_exec('Create user (bob)').
              only_with(command: exec_command,
                        unless: read_command,
                        require: 'Exec[cassandra::schema connection test]')
          end
        end

        context 'with ensure => absent' do
          let(:params) do
            super().merge({ 'ensure' => 'absent' })
          end

          it 'drops a user' do
            read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST ROLES\" localhost 9042 | grep \'\s*bob |\'"'
            exec_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DROP ROLE bob\" localhost 9042"'
            expect(subject).to contain_exec('Delete user (bob)').
              only_with(command: exec_command,
                        onlyif: read_command,
                        require: 'Exec[cassandra::schema connection test]')
          end
        end
      end
    end

    context 'when cassandrarelease < 2.2' do
      let :facts do
        os_facts.merge({
                         cassandrarelease: '2.1.0',
                       })
      end

      context 'with use_scl => false' do
        context 'with superuser => true' do
          let(:params) do
            super().merge({
                            'superuser' => true
                          })
          end

          it 'creates a superuser' do
            expect(subject).to contain_cassandra__schema__user('bob').with_ensure('present')
            read_command = '/usr/bin/cqlsh   -e "LIST USERS" localhost 9042 | grep \'\s*bob |\''
            exec_command =  '/usr/bin/cqlsh   -e "CREATE USER IF NOT EXISTS bob'
            exec_command += ' WITH PASSWORD \'Niner2\' SUPERUSER" localhost 9042'
            expect(subject).to contain_exec('Create user (bob)').
              only_with(command: exec_command,
                        unless: read_command,
                        require: 'Exec[cassandra::schema connection test]')
          end
        end

        context 'with login => false' do
          let(:params) do
            super().merge({
                            'login' => false
                          })
          end

          it 'creates a user' do
            expect(subject).to contain_cassandra__schema__user('bob').with_ensure('present')
            read_command = '/usr/bin/cqlsh   -e "LIST USERS" localhost 9042 | grep \'\s*bob |\''
            exec_command =  '/usr/bin/cqlsh   -e "CREATE USER IF NOT EXISTS bob'
            exec_command += ' WITH PASSWORD \'Niner2\' NOSUPERUSER" localhost 9042'
            expect(subject).to contain_exec('Create user (bob)').
              only_with(command: exec_command,
                        unless: read_command,
                        require: 'Exec[cassandra::schema connection test]')
          end
        end

        context 'with ensure => absent' do
          let(:params) do
            super().merge({
                            'ensure' => 'absent'
                          })
          end

          it 'drops a user' do
            read_command = '/usr/bin/cqlsh   -e "LIST USERS" localhost 9042 | grep \'\s*bob |\''
            exec_command = '/usr/bin/cqlsh   -e "DROP USER bob" localhost 9042'
            expect(subject).to contain_exec('Delete user (bob)').
              only_with(command: exec_command,
                        onlyif: read_command,
                        require: 'Exec[cassandra::schema connection test]')
          end
        end
      end

      context 'with use_scl => true' do
        let(:params) do
          super().merge({
                          'use_scl'  => true,
                          'scl_name' => 'testscl',
                        })
        end

        context 'with superuser => true' do
          let(:params) do
            super().merge({
                            'superuser' => true
                          })
          end

          it 'creates a superuser' do
            expect(subject).to contain_cassandra__schema__user('bob').with_ensure('present')
            read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST USERS\" localhost 9042 | grep \'\s*bob |\'"'
            exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE USER IF NOT EXISTS bob'
            exec_command += ' WITH PASSWORD \'Niner2\' SUPERUSER\" localhost 9042"'
            expect(subject).to contain_exec('Create user (bob)').
              only_with(command: exec_command,
                        unless: read_command,
                        require: 'Exec[cassandra::schema connection test]')
          end
        end

        context 'with login => false' do
          let(:params) do
            super().merge({
                            'login' => false
                          })
          end

          it 'creates user without login' do
            expect(subject).to contain_cassandra__schema__user('bob').with_ensure('present')
            read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST USERS\" localhost 9042 | grep \'\s*bob |\'"'
            exec_command =  '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"CREATE USER IF NOT EXISTS bob'
            exec_command += ' WITH PASSWORD \'Niner2\' NOSUPERUSER\" localhost 9042"'
            expect(subject).to contain_exec('Create user (bob)').
              only_with(command: exec_command,
                        unless: read_command,
                        require: 'Exec[cassandra::schema connection test]')
          end
        end

        context 'with ensure => absent' do
          let(:params) do
            super().merge({
                            'ensure' => 'absent'
                          })
          end

          it 'drops a user' do
            read_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"LIST USERS\" localhost 9042 | grep \'\s*bob |\'"'
            exec_command = '/usr/bin/scl enable testscl "/usr/bin/cqlsh   -e \"DROP USER bob\" localhost 9042"'
            expect(subject).to contain_exec('Delete user (bob)').
              only_with(command: exec_command,
                        onlyif: read_command,
                        require: 'Exec[cassandra::schema connection test]')
          end
        end
      end
    end

    context 'Set ensure to latest' do
      let(:params) do
        {
          ensure: 'latest'
        }
      end

      it { is_expected.to raise_error(Puppet::Error) }
    end
  end
end
