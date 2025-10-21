# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  install_puppet_module_via_pmt_on(host, 'puppetlabs-apt') if fact_on(host, 'os.family') == 'Debian'
  install_puppet_module_via_pmt_on(host, 'puppetlabs-stdlib')
  install_puppet_module_via_pmt_on(host, 'puppetlabs-yumrepo_core') if fact_on(host, 'os.family') == 'RedHat'
end
