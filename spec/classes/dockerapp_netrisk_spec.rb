# frozen_string_literal: true

require 'spec_helper'

describe 'dockerapp_netrisk' do

  let(:node) { 'node1.test.com' }
  let(:params) do
    {
      service_name: 'nettest',
      version: '1.4.1',

    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('dockerapp').with(
        manage_docker: false
        ) }

      it { is_expected.to contain_file('/srv/application-data/nettest') }
      it { is_expected.to contain_file('/srv/application-data/nettest/backups') }
      it { is_expected.to contain_file('/srv/application-data/nettest/api') }
      it { is_expected.to contain_file('/srv/application-data/nettest/website') }

    end
  end
end
