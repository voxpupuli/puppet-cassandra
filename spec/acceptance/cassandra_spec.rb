require 'spec_helper_acceptance'
describe 'cassandra' do
  roles = hosts[0]['roles']
  versions = []
  versions.push(2) if roles.include? 'cassandra2'
  versions.push(3) if roles.include? 'cassandra3'

  it "should run successfully #{versions}" do
    pp = "notify { 'Hello, world!': }"

    apply_manifest(pp, catch_failures: true) do |r|
      expect(r.stderr).not_to match(/error/i)
    end
  end
end
