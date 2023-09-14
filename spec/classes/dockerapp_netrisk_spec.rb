# frozen_string_literal: true

require 'spec_helper'


describe 'dockerapp_netrisk' do

  let(:node) { 'node1.test.com' }

  context 'without db_server' do
    
    let(:params) do
      {
        service_name: 'nettest',
        version: '1.4.1',
      }
    end

    it { is_expected.to compile.and_raise_error(/db_server cannot be empty/)}
  end

  context 'without db_password' do
    
    let(:params) do
      {
        service_name: 'nettest',
        version: '1.4.1',
        db_server: 'testedb',
      }
    end

    it { is_expected.to compile.and_raise_error(/db_password is mandatory/)}
  end

  context 'without api_ssl_cert_file' do
    
    let(:params) do
      {
        service_name: 'nettest',
        version: '1.4.1',
        db_server: 'testedb',
        db_password: 'testepwd',
      }
    end

    it { is_expected.to compile.and_raise_error(/api_ssl_cert_file is mandatory/)}
  end

  context 'without api_ssl_cert_pwd' do
    
    let(:params) do
      {
        service_name: 'nettest',
        version: '1.4.1',
        db_server: 'testedb',
        db_password: 'testepwd',
        api_ssl_cert_file: '/sslfile.pfx',
      }
    end

    it { is_expected.to compile.and_raise_error(/api_ssl_cert_pwd is mandatory/)}
  end

  context 'without website_ssl_cert_file' do
    
    let(:params) do
      {
        service_name: 'nettest',
        version: '1.4.1',
        db_server: 'testedb',
        db_password: 'testepwd',
        api_ssl_cert_file: '/sslfile.pfx',
        api_ssl_cert_pwd: '123',
      }
    end

    it { is_expected.to compile.and_raise_error(/website_ssl_cert_file is mandatory/)}
  end

    context 'without website_ssl_cert_pwd' do
    
    let(:params) do
      {
        service_name: 'nettest',
        version: '1.4.1',
        db_server: 'testedb',
        db_password: 'testepwd',
        api_ssl_cert_file: '/sslfile.pfx',
        api_ssl_cert_pwd: '123',
        website_ssl_cert_file: '/ws_sslfile.pfx',
      }
    end

    it { is_expected.to compile.and_raise_error(/website_ssl_cert_pwd is mandatory/)}
  end


  context 'working example' do
  
    let(:params) do
      {
        service_name: 'nettest',
        version: '1.4.1',
        db_server: 'testedb',
        db_password: 'testepwd',
        api_ssl_cert_file: '/sslfile.pfx',
        api_ssl_cert_pwd: '123',
        website_ssl_cert_file: '/ws_sslfile.pfx',
        website_ssl_cert_pwd: '1234'

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
        it { is_expected.to contain_file('/srv/application-config/nettest') }
        it { is_expected.to contain_file('/srv/application-config/nettest/api') }
        it { is_expected.to contain_file('/srv/application-config/nettest/configurations') }
        it { is_expected.to contain_file('/srv/application-config/nettest/ssl') }
        it { is_expected.to contain_file('/srv/application-config/nettest/website') }
        it { is_expected.to contain_file('/srv/scripts/nettest') }
        it { is_expected.to contain_file('/srv/application-log/nettest') }
        it { is_expected.to contain_file('/srv/application-log/nettest/website') }
        it { is_expected.to contain_file('/srv/application-log/nettest/api') }
        it { is_expected.to contain_file('/srv/application-config/nettest/api/certs') }
        it { is_expected.to contain_file('/srv/application-config/nettest/api/certs/api.pfx') }
        it { is_expected.to contain_file('/srv/application-config/nettest/website/certs/website.pfx') }
        it { is_expected.to contain_file('/srv/application-config/nettest/website/certs') }

      end
    end
  end
end
