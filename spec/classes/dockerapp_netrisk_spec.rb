# frozen_string_literal: true

require 'spec_helper'

describe 'dockerapp_netrisk' do
  let(:node) { 'node1.test.com' }

  test_on = {
    supported_os: [
      {
        'operatingsystem'        => 'Debian',
        'operatingsystemrelease' => ['10'],
      },
    ],
  }

  on_supported_os(test_on).each do |_os, os_facts1|
    let(:facts) { os_facts1 }

    context 'without db_server' do
      let(:params) do
        {
          service_name: 'nettest',
          version: '1.4.1',
        }
      end

      it { is_expected.to compile.and_raise_error(%r{db_server cannot be empty}) }
    end

    context 'without db_password' do
      let(:params) do
        {
          service_name: 'nettest',
          version: '1.4.1',
          db_server: 'testedb',
        }
      end

      it { is_expected.to compile.and_raise_error(%r{db_password is mandatory}) }
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

      it { is_expected.to compile.and_raise_error(%r{api_ssl_cert_file is mandatory}) }
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

      it { is_expected.to compile.and_raise_error(%r{api_ssl_cert_pwd is mandatory}) }
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

      it { is_expected.to compile.and_raise_error(%r{website_ssl_cert_file is mandatory}) }
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

      it { is_expected.to compile.and_raise_error(%r{website_ssl_cert_pwd is mandatory}) }
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
          idp_certificate: '/api.pem',
          sp_certificate_file: '/sp.pfx',
          sp_certificate_pwd: '123',
          website_ssl_cert_file: '/ws_sslfile.pfx',
          website_ssl_cert_pwd: '1234',
          enable_saml: false

        }
      end

      on_supported_os.each do |os, os_facts|
        context "on #{os}" do
          let(:facts) { os_facts }

          it { is_expected.to compile }
          it {
            is_expected.to contain_class('dockerapp').with(manage_docker: false)
          }

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
          it { is_expected.to contain_file('/srv/application-config/nettest/backgroundjobs') }
          it { is_expected.to contain_file('/srv/application-log/nettest/backgroundjobs') }
          it { is_expected.to contain_file('/srv/application-data/nettest/backgroundjobs') }
          it { is_expected.to contain_file('/usr/local/bin/netrisk-console') }
          it { is_expected.to contain_file('/srv/application-config/nettest/api/certs/idp.pem') }
          it { is_expected.to contain_file('/srv/application-config/nettest/api/certs/sp.pfx') }
          it { is_expected.to contain_file('/srv/application-log/nettest/console') }
          it { is_expected.to contain_file('/srv/application-data/nettest/console') }

          it {
            is_expected.to contain_file('/srv/application-data/nettest/api/appdata').with(
              ensure: 'directory',
              owner: 'netrisk',
              mode: '0700',
            )
          }
          it {
            is_expected.to contain_file('/srv/application-data/nettest/console/appdata').with(
              ensure: 'directory',
              owner: 'netrisk',
              mode: '0700',
            )
          }
          it {
            is_expected.to contain_file('/srv/application-data/nettest/backgroundjobs/appdata').with(
              ensure: 'directory',
              owner: 'netrisk',
              mode: '0700',
            )
          }

          it {
            is_expected.to contain_User('netrisk').with(
              home: '/srv/application-config/nettest',
              uid: 7070,
            )
          }

          it { is_expected.to contain_Docker_network('nettest-net') }

          it {
            is_expected.to contain_dockerapp__run('nettest_api')
              .with(
                image: 'ffquintella/netrisk-api:1.4.1',
                ports: ['5443:5443'],
                volumes: [
                  '/srv/application-config/nettest/api/certs/api.pfx:/netrisk/api.pfx',
                  '/srv/application-config/nettest/api/certs/idp.pem:/netrisk/idp.pem',
                  '/srv/application-config/nettest/api/certs/sp.pfx:/netrisk/sp.pfx',
                  '/srv/application-log/nettest/api:/var/log/netrisk',
                  '/srv/application-data/nettest/api/plugins:/netrisk/Plugins',
                  '/srv/application-data/nettest/api/appdata:/var/netrisk',
                ],
                environments: [
                  'FACTER_ENABLE_SAML=false',
                  'FACTER_DBSERVER=testedb',
                  'FACTER_DBUSER=netrisk',
                  'FACTER_DBPORT=3306',
                  'FACTER_DBPASSWORD=testepwd',
                  'FACTER_DBSCHEMA=netrisk',
                  'FACTER_NETRISK_URL=https://node1.test.com:5443',
                  'FACTER_SERVER_LOGGING=Information',
                  'FACTER_EMAIL_FROM=netrisk@mail.com',
                  'FACTER_EMAIL_SERVER=localhost',
                  'FACTER_EMAIL_PORT=25',
                  'FACTER_SERVER_CERTIFICATE_FILE=/netrisk/api.pfx',
                  'FACTER_SERVER_CERTIFICATE_PWD=123',
                  'FACTER_WEBSITE_PROTOCOL=https',
                  'FACTER_WEBSITE_HOST=node1.test.com',
                  'FACTER_WEBSITE_PORT=443',
                  'FACTER_NETRISK_USER=netrisk',
                  'FACTER_NETRISK_UID=7070',
                  'FACTER_IDP_NAME=SAML',
                  'FACTER_IDP_ENTITY_ID=',
                  'FACTER_IDP_SSO_SERVICE=',
                  'FACTER_IDP_SSOUT_SERVICE=',
                  'FACTER_IDP_ARTIFACT_RESOLVE_SRVC=',
                  'FACTER_IDP_CERTIFICATE_FILE=/netrisk/idp.pem',
                  'FACTER_SP_CERTIFICATE_FILE=/netrisk/sp.pfx',
                  'FACTER_SP_CERTIFICATE_PWD=123',
                ],
              )
          }

          it {
            is_expected.to contain_dockerapp__run('nettest_website')
              .with(
                image: 'ffquintella/netrisk-website:1.4.1',
                ports: ['443:443'],
                volumes: [
                  '/srv/application-config/nettest/website/certs/website.pfx:/netrisk/website.pfx',
                  '/srv/application-log/nettest/website:/var/log/netrisk',
                ],
                environments: [
                  'FACTER_DBSERVER=testedb',
                  'FACTER_DBUSER=netrisk',
                  'FACTER_DBPORT=3306',
                  'FACTER_DBPASSWORD=testepwd',
                  'FACTER_DBSCHEMA=netrisk',
                  'FACTER_NETRISK_URL=https://node1.test.com:5443',
                  'FACTER_SERVER_LOGGING=Information',
                  'FACTER_EMAIL_FROM=netrisk@mail.com',
                  'FACTER_EMAIL_SERVER=localhost',
                  'FACTER_EMAIL_PORT=25',
                  'FACTER_SERVER_CERTIFICATE_FILE=/netrisk/website.pfx',
                  'FACTER_SERVER_CERTIFICATE_PWD=1234',
                  'FACTER_WEBSITE_PROTOCOL=https',
                  'FACTER_WEBSITE_HOST=node1.test.com',
                  'FACTER_WEBSITE_PORT=443',
                  "FACTER_SERVER_HTTPS_PORT=443",
                  'FACTER_ENABLE_SAML=false',
                  'FACTER_NETRISK_USER=netrisk',
                  'FACTER_NETRISK_UID=7070',
                ],
              )
          }

          it {
            is_expected.to contain_dockerapp__run('nettest_console')
              .with(
                image: 'ffquintella/netrisk-console:1.4.1',
                volumes: [
                  '/srv/application-data/nettest/backups:/backups',
                  '/srv/application-log/nettest/console:/var/log/netrisk',
                  '/srv/application-data/nettest/console/appdata:/var/netrisk',
                ],
                environments: [
                  'FACTER_DBSERVER=testedb',
                  'FACTER_DBUSER=netrisk',
                  'FACTER_DBPORT=3306',
                  'FACTER_DBPASSWORD=testepwd',
                  'FACTER_DBSCHEMA=netrisk',
                  'FACTER_SERVER_LOGGING=Information',
                  'FACTER_NETRISK_USER=netrisk',
                  'FACTER_NETRISK_UID=7070',
                ],
              )
          }

          it {
            is_expected.to contain_dockerapp__run('nettest_backgroundjobs')
              .with(
                image: 'ffquintella/netrisk-backgroundjobs:1.4.1',
                volumes: [
                  '/srv/application-data/nettest/backups:/backups',
                  '/srv/application-log/nettest/backgroundjobs:/var/log/netrisk',
                  '/srv/application-data/nettest/backgroundjobs/appdata:/var/netrisk',
                ],
                environments: [
                  'FACTER_NETRISK_URL=https://node1.test.com:5443',
                  'FACTER_DBSERVER=testedb',
                  'FACTER_DBUSER=netrisk',
                  'FACTER_DBPORT=3306',
                  'FACTER_DBPASSWORD=testepwd',
                  'FACTER_DBSCHEMA=netrisk',
                  'FACTER_SERVER_LOGGING=Information',
                  'FACTER_NETRISK_USER=netrisk',
                  'FACTER_NETRISK_UID=7070',
                ],
              )
          }
        end
      end
    end

    context 'with a secret_master_key' do
      let(:params) do
        {
          service_name: 'nettest',
          version: '1.4.1',
          db_server: 'testedb',
          db_password: 'testepwd',
          api_ssl_cert_file: '/sslfile.pfx',
          api_ssl_cert_pwd: '123',
          idp_certificate: '/api.pem',
          sp_certificate_file: '/sp.pfx',
          sp_certificate_pwd: '123',
          website_ssl_cert_file: '/ws_sslfile.pfx',
          website_ssl_cert_pwd: '1234',
          enable_saml: false,
          secret_master_key: 'Yy8OaM3jVQKDe+gRZtnGdS1rWpXlHu7cIbA4FkNPqT0=',
        }
      end

      it { is_expected.to compile }

      it {
        is_expected.to contain_dockerapp__run('nettest_api')
          .with(
            environments: [
              'FACTER_ENABLE_SAML=false',
              'FACTER_DBSERVER=testedb',
              'FACTER_DBUSER=netrisk',
              'FACTER_DBPORT=3306',
              'FACTER_DBPASSWORD=testepwd',
              'FACTER_DBSCHEMA=netrisk',
              'FACTER_NETRISK_URL=https://node1.test.com:5443',
              'FACTER_SERVER_LOGGING=Information',
              'FACTER_EMAIL_FROM=netrisk@mail.com',
              'FACTER_EMAIL_SERVER=localhost',
              'FACTER_EMAIL_PORT=25',
              'FACTER_SERVER_CERTIFICATE_FILE=/netrisk/api.pfx',
              'FACTER_SERVER_CERTIFICATE_PWD=123',
              'FACTER_WEBSITE_PROTOCOL=https',
              'FACTER_WEBSITE_HOST=node1.test.com',
              'FACTER_WEBSITE_PORT=443',
              'FACTER_NETRISK_USER=netrisk',
              'FACTER_NETRISK_UID=7070',
              'FACTER_IDP_NAME=SAML',
              'FACTER_IDP_ENTITY_ID=',
              'FACTER_IDP_SSO_SERVICE=',
              'FACTER_IDP_SSOUT_SERVICE=',
              'FACTER_IDP_ARTIFACT_RESOLVE_SRVC=',
              'FACTER_IDP_CERTIFICATE_FILE=/netrisk/idp.pem',
              'FACTER_SP_CERTIFICATE_FILE=/netrisk/sp.pfx',
              'FACTER_SP_CERTIFICATE_PWD=123',
              'FACTER_SECRET_MASTER_KEY=Yy8OaM3jVQKDe+gRZtnGdS1rWpXlHu7cIbA4FkNPqT0=',
            ],
          )
      }

      it {
        is_expected.to contain_dockerapp__run('nettest_console')
          .with(
            environments: [
              'FACTER_DBSERVER=testedb',
              'FACTER_DBUSER=netrisk',
              'FACTER_DBPORT=3306',
              'FACTER_DBPASSWORD=testepwd',
              'FACTER_DBSCHEMA=netrisk',
              'FACTER_SERVER_LOGGING=Information',
              'FACTER_NETRISK_USER=netrisk',
              'FACTER_NETRISK_UID=7070',
              'FACTER_SECRET_MASTER_KEY=Yy8OaM3jVQKDe+gRZtnGdS1rWpXlHu7cIbA4FkNPqT0=',
            ],
          )
      }

      it {
        is_expected.to contain_dockerapp__run('nettest_backgroundjobs')
          .with(
            environments: [
              'FACTER_NETRISK_URL=https://node1.test.com:5443',
              'FACTER_DBSERVER=testedb',
              'FACTER_DBUSER=netrisk',
              'FACTER_DBPORT=3306',
              'FACTER_DBPASSWORD=testepwd',
              'FACTER_DBSCHEMA=netrisk',
              'FACTER_SERVER_LOGGING=Information',
              'FACTER_NETRISK_USER=netrisk',
              'FACTER_NETRISK_UID=7070',
              'FACTER_SECRET_MASTER_KEY=Yy8OaM3jVQKDe+gRZtnGdS1rWpXlHu7cIbA4FkNPqT0=',
            ],
          )
      }

      # The website container has no credential store; the key must not leak
      # into it. This exact-array match is what proves the absence.
      it {
        is_expected.to contain_dockerapp__run('nettest_website')
          .with(
            environments: [
              'FACTER_DBSERVER=testedb',
              'FACTER_DBUSER=netrisk',
              'FACTER_DBPORT=3306',
              'FACTER_DBPASSWORD=testepwd',
              'FACTER_DBSCHEMA=netrisk',
              'FACTER_NETRISK_URL=https://node1.test.com:5443',
              'FACTER_SERVER_LOGGING=Information',
              'FACTER_EMAIL_FROM=netrisk@mail.com',
              'FACTER_EMAIL_SERVER=localhost',
              'FACTER_EMAIL_PORT=25',
              'FACTER_SERVER_CERTIFICATE_FILE=/netrisk/website.pfx',
              'FACTER_SERVER_CERTIFICATE_PWD=1234',
              'FACTER_WEBSITE_PROTOCOL=https',
              'FACTER_WEBSITE_HOST=node1.test.com',
              'FACTER_WEBSITE_PORT=443',
              'FACTER_SERVER_HTTPS_PORT=443',
              'FACTER_ENABLE_SAML=false',
              'FACTER_NETRISK_USER=netrisk',
              'FACTER_NETRISK_UID=7070',
            ],
          )
      }
    end

    context 'with a secret_master_key that is not base64' do
      let(:params) do
        {
          service_name: 'nettest',
          version: '1.4.1',
          db_server: 'testedb',
          db_password: 'testepwd',
          api_ssl_cert_file: '/sslfile.pfx',
          api_ssl_cert_pwd: '123',
          website_ssl_cert_file: '/ws_sslfile.pfx',
          website_ssl_cert_pwd: '1234',
          secret_master_key: 'not a base64 key at all!!!!!!!!!!!!!!!!!!!!!',
        }
      end

      it { is_expected.to compile.and_raise_error(%r{secret_master_key}) }
    end

    context 'with a secret_master_key of the wrong length' do
      let(:params) do
        {
          service_name: 'nettest',
          version: '1.4.1',
          db_server: 'testedb',
          db_password: 'testepwd',
          api_ssl_cert_file: '/sslfile.pfx',
          api_ssl_cert_pwd: '123',
          website_ssl_cert_file: '/ws_sslfile.pfx',
          website_ssl_cert_pwd: '1234',
          secret_master_key: 'c2hvcnRrZXk=',
        }
      end

      it { is_expected.to compile.and_raise_error(%r{secret_master_key must be the base64 encoding of exactly 32 bytes}) }
    end
  end
end
