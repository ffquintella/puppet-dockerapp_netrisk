# frozen_string_literal: true

require 'spec_helper'

# FerroGate MIA (Machine Identity Agent) support: only the api and
# backgroundjobs containers may ever receive it.
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

    let(:base_params) do
      {
        service_name: 'nettest',
        version: '2.50.0',
        db_server: 'testedb',
        db_password: sensitive('testepwd'),
        api_ssl_cert_file: '/sslfile.pfx',
        api_ssl_cert_pwd: sensitive('123'),
        idp_certificate: '/api.pem',
        sp_certificate_file: '/sp.pfx',
        sp_certificate_pwd: sensitive('123'),
        website_ssl_cert_file: '/ws_sslfile.pfx',
        website_ssl_cert_pwd: sensitive('1234'),
      }
    end


    context 'with mia_mode off (default)' do
      let(:params) { base_params }

      it { is_expected.to compile }
      it { is_expected.to contain_dockerapp__run('nettest_api').with(volumes: [
            '/srv/application-config/nettest/api/certs/api.pfx:/netrisk/api.pfx',
            '/srv/application-config/nettest/api/certs/idp.pem:/netrisk/idp.pem',
            '/srv/application-config/nettest/api/certs/sp.pfx:/netrisk/sp.pfx',
            '/srv/application-log/nettest/api:/var/log/netrisk',
            '/srv/application-data/nettest/api/plugins:/netrisk/Plugins',
            '/srv/application-data/nettest/api/appdata:/var/netrisk',
          ]) }
      it { is_expected.to contain_dockerapp__run('nettest_backgroundjobs').with(volumes: [
            '/srv/application-data/nettest/backups:/backups',
            '/srv/application-log/nettest/backgroundjobs:/var/log/netrisk',
            '/srv/application-data/nettest/backgroundjobs/appdata:/var/netrisk',
          ], environments: [
            'FACTER_NETRISK_URL=https://node1.test.com:5443',
            'FACTER_DBSERVER=testedb',
            'FACTER_DBUSER=netrisk',
            'FACTER_DBPORT=3306',
            'FACTER_DBPASSWORD=testepwd',
            'FACTER_DBSCHEMA=netrisk',
            'FACTER_SERVER_LOGGING=Information',
            'FACTER_NETRISK_USER=netrisk',
            'FACTER_NETRISK_UID=7070',
          ]) }
      it { is_expected.not_to contain_docker_volume('nettest-mia-api') }
      it { is_expected.not_to contain_file('/srv/application-config/nettest/mia') }
      it {
        is_expected.to contain_dockerapp__run('nettest_console')
          .with(volumes: [
            '/srv/application-data/nettest/backups:/backups',
            '/srv/application-log/nettest/console:/var/log/netrisk',
            '/srv/application-data/nettest/console/appdata:/var/netrisk',
          ], environments: [
            'FACTER_DBSERVER=testedb',
            'FACTER_DBUSER=netrisk',
            'FACTER_DBPORT=3306',
            'FACTER_DBPASSWORD=testepwd',
            'FACTER_DBSCHEMA=netrisk',
            'FACTER_SERVER_LOGGING=Information',
            'FACTER_NETRISK_USER=netrisk',
            'FACTER_NETRISK_UID=7070',
          ])
      }

      it {
        is_expected.to contain_dockerapp__run('nettest_website')
          .with(volumes: [
            '/srv/application-config/nettest/website/certs/website.pfx:/netrisk/website.pfx',
            '/srv/application-log/nettest/website:/var/log/netrisk',
          ], environments: [
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
          ])
      }
    end

    context 'with mia_mode off and other mia_* parameters set' do
      let(:params) { base_params.merge(mia_required: true, mia_cmis_endpoint: 'https://cmis:8443', mia_env: { 'FERROGATE_X' => 'y' }) }

      it { is_expected.to contain_dockerapp__run('nettest_api').with(volumes: [
            '/srv/application-config/nettest/api/certs/api.pfx:/netrisk/api.pfx',
            '/srv/application-config/nettest/api/certs/idp.pem:/netrisk/idp.pem',
            '/srv/application-config/nettest/api/certs/sp.pfx:/netrisk/sp.pfx',
            '/srv/application-log/nettest/api:/var/log/netrisk',
            '/srv/application-data/nettest/api/plugins:/netrisk/Plugins',
            '/srv/application-data/nettest/api/appdata:/var/netrisk',
          ]) }
      it { is_expected.to contain_dockerapp__run('nettest_backgroundjobs').with(volumes: [
            '/srv/application-data/nettest/backups:/backups',
            '/srv/application-log/nettest/backgroundjobs:/var/log/netrisk',
            '/srv/application-data/nettest/backgroundjobs/appdata:/var/netrisk',
          ], environments: [
            'FACTER_NETRISK_URL=https://node1.test.com:5443',
            'FACTER_DBSERVER=testedb',
            'FACTER_DBUSER=netrisk',
            'FACTER_DBPORT=3306',
            'FACTER_DBPASSWORD=testepwd',
            'FACTER_DBSCHEMA=netrisk',
            'FACTER_SERVER_LOGGING=Information',
            'FACTER_NETRISK_USER=netrisk',
            'FACTER_NETRISK_UID=7070',
          ]) }
      it {
        is_expected.to contain_dockerapp__run('nettest_console')
          .with(volumes: [
            '/srv/application-data/nettest/backups:/backups',
            '/srv/application-log/nettest/console:/var/log/netrisk',
            '/srv/application-data/nettest/console/appdata:/var/netrisk',
          ], environments: [
            'FACTER_DBSERVER=testedb',
            'FACTER_DBUSER=netrisk',
            'FACTER_DBPORT=3306',
            'FACTER_DBPASSWORD=testepwd',
            'FACTER_DBSCHEMA=netrisk',
            'FACTER_SERVER_LOGGING=Information',
            'FACTER_NETRISK_USER=netrisk',
            'FACTER_NETRISK_UID=7070',
          ])
      }

      it {
        is_expected.to contain_dockerapp__run('nettest_website')
          .with(volumes: [
            '/srv/application-config/nettest/website/certs/website.pfx:/netrisk/website.pfx',
            '/srv/application-log/nettest/website:/var/log/netrisk',
          ], environments: [
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
          ])
      }
    end

    context 'embedded with a named volume' do
      let(:params) do
        base_params.merge(
          mia_mode: 'embedded',
          mia_cmis_endpoint: 'https://cmis.example.com:8443',
          mia_cmis_spki_pin: 'sha256/abc=',
        )
      end

      it { is_expected.to compile }

      # The exact array is the guard: dropping /var/lib/ferrogate fails this.
      it {
        is_expected.to contain_dockerapp__run('nettest_api').with(
          volumes: [
            '/srv/application-config/nettest/api/certs/api.pfx:/netrisk/api.pfx',
            '/srv/application-config/nettest/api/certs/idp.pem:/netrisk/idp.pem',
            '/srv/application-config/nettest/api/certs/sp.pfx:/netrisk/sp.pfx',
            '/srv/application-log/nettest/api:/var/log/netrisk',
            '/srv/application-data/nettest/api/plugins:/netrisk/Plugins',
            '/srv/application-data/nettest/api/appdata:/var/netrisk',
            'nettest-mia-api:/var/lib/ferrogate',
          ],
        )
      }

      it {
        is_expected.to contain_dockerapp__run('nettest_backgroundjobs').with(
          volumes: [
            '/srv/application-data/nettest/backups:/backups',
            '/srv/application-log/nettest/backgroundjobs:/var/log/netrisk',
            '/srv/application-data/nettest/backgroundjobs/appdata:/var/netrisk',
            'nettest-mia-backgroundjobs:/var/lib/ferrogate',
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
            'MIA_MODE=embedded',
            'MIA_REQUIRED=0',
            'FERROGATE_CMIS_ENDPOINT=https://cmis.example.com:8443',
            'FERROGATE_CMIS_SPKI_PIN=sha256/abc=',
          ],
        )
      }

      it { is_expected.to contain_docker_volume('nettest-mia-api').with(ensure: 'present') }
      it { is_expected.to contain_docker_volume('nettest-mia-backgroundjobs').with(ensure: 'present') }
      it {
        is_expected.to contain_dockerapp__run('nettest_console')
          .with(volumes: [
            '/srv/application-data/nettest/backups:/backups',
            '/srv/application-log/nettest/console:/var/log/netrisk',
            '/srv/application-data/nettest/console/appdata:/var/netrisk',
          ], environments: [
            'FACTER_DBSERVER=testedb',
            'FACTER_DBUSER=netrisk',
            'FACTER_DBPORT=3306',
            'FACTER_DBPASSWORD=testepwd',
            'FACTER_DBSCHEMA=netrisk',
            'FACTER_SERVER_LOGGING=Information',
            'FACTER_NETRISK_USER=netrisk',
            'FACTER_NETRISK_UID=7070',
          ])
      }

      it {
        is_expected.to contain_dockerapp__run('nettest_website')
          .with(volumes: [
            '/srv/application-config/nettest/website/certs/website.pfx:/netrisk/website.pfx',
            '/srv/application-log/nettest/website:/var/log/netrisk',
          ], environments: [
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
          ])
      }
    end

    context 'embedded with every dedicated parameter, mia_required and mia_env' do
      let(:params) do
        base_params.merge(
          mia_mode: 'embedded',
          mia_required: true,
          mia_cmis_endpoint: 'https://cmis.example.com:8443',
          mia_cmis_srv: '_cmis._tcp.example.com',
          mia_cmis_spki_pin: 'sha256/abc=',
          mia_allowlist_key: 'allow-key',
          mia_env: { 'FERROGATE_ZED' => 'z', 'FERROGATE_ALLOWLIST_FETCH' => sensitive('https://cmis/allow') },
          mia_state_volume: 'ident',
        )
      end

      it {
        is_expected.to contain_dockerapp__run('nettest_api').with(
          volumes: [
            '/srv/application-config/nettest/api/certs/api.pfx:/netrisk/api.pfx',
            '/srv/application-config/nettest/api/certs/idp.pem:/netrisk/idp.pem',
            '/srv/application-config/nettest/api/certs/sp.pfx:/netrisk/sp.pfx',
            '/srv/application-log/nettest/api:/var/log/netrisk',
            '/srv/application-data/nettest/api/plugins:/netrisk/Plugins',
            '/srv/application-data/nettest/api/appdata:/var/netrisk',
            'ident-api:/var/lib/ferrogate',
          ],
        )
      }

      it {
        # mia_env is emitted sorted by key, after the dedicated variables
        is_expected.to contain_dockerapp__run('nettest_backgroundjobs').with(
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
            'MIA_MODE=embedded',
            'MIA_REQUIRED=1',
            'FERROGATE_CMIS_ENDPOINT=https://cmis.example.com:8443',
            'FERROGATE_CMIS_SRV=_cmis._tcp.example.com',
            'FERROGATE_CMIS_SPKI_PIN=sha256/abc=',
            'FERROGATE_ALLOWLIST_KEY=allow-key',
            'FERROGATE_ALLOWLIST_FETCH=https://cmis/allow',
            'FERROGATE_ZED=z',
          ],
        )
      }

      it { is_expected.to contain_docker_volume('ident-api') }
      it {
        is_expected.to contain_dockerapp__run('nettest_console')
          .with(volumes: [
            '/srv/application-data/nettest/backups:/backups',
            '/srv/application-log/nettest/console:/var/log/netrisk',
            '/srv/application-data/nettest/console/appdata:/var/netrisk',
          ], environments: [
            'FACTER_DBSERVER=testedb',
            'FACTER_DBUSER=netrisk',
            'FACTER_DBPORT=3306',
            'FACTER_DBPASSWORD=testepwd',
            'FACTER_DBSCHEMA=netrisk',
            'FACTER_SERVER_LOGGING=Information',
            'FACTER_NETRISK_USER=netrisk',
            'FACTER_NETRISK_UID=7070',
          ])
      }

      it {
        is_expected.to contain_dockerapp__run('nettest_website')
          .with(volumes: [
            '/srv/application-config/nettest/website/certs/website.pfx:/netrisk/website.pfx',
            '/srv/application-log/nettest/website:/var/log/netrisk',
          ], environments: [
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
          ])
      }
    end

    context 'embedded with a host directory for the identity' do
      let(:params) do
        base_params.merge(mia_mode: 'embedded', mia_cmis_srv: '_cmis._tcp.example.com',
                          mia_state_mode: 'directory', mia_state_dir: '/srv/mia-state')
      end

      it { is_expected.to compile }
      it { is_expected.to contain_file('/srv/mia-state').with(ensure: 'directory', mode: '0700') }
      it { is_expected.to contain_file('/srv/mia-state/api').with(ensure: 'directory', mode: '0700') }
      it { is_expected.to contain_file('/srv/mia-state/backgroundjobs').with(ensure: 'directory', mode: '0700') }
      it { is_expected.not_to contain_docker_volume('nettest-mia-api') }

      it {
        is_expected.to contain_dockerapp__run('nettest_api').with(
          volumes: [
            '/srv/application-config/nettest/api/certs/api.pfx:/netrisk/api.pfx',
            '/srv/application-config/nettest/api/certs/idp.pem:/netrisk/idp.pem',
            '/srv/application-config/nettest/api/certs/sp.pfx:/netrisk/sp.pfx',
            '/srv/application-log/nettest/api:/var/log/netrisk',
            '/srv/application-data/nettest/api/plugins:/netrisk/Plugins',
            '/srv/application-data/nettest/api/appdata:/var/netrisk',
            '/srv/mia-state/api:/var/lib/ferrogate',
          ],
        )
      }

      it {
        is_expected.to contain_dockerapp__run('nettest_backgroundjobs').with(
          volumes: [
            '/srv/application-data/nettest/backups:/backups',
            '/srv/application-log/nettest/backgroundjobs:/var/log/netrisk',
            '/srv/application-data/nettest/backgroundjobs/appdata:/var/netrisk',
            '/srv/mia-state/backgroundjobs:/var/lib/ferrogate',
          ],
        )
      }
    end

    context 'embedded with mia_config_source' do
      let(:params) do
        base_params.merge(mia_mode: 'embedded', mia_config_source: '/etc/mia-host.toml')
      end

      it { is_expected.to compile }
      it { is_expected.to contain_file('/srv/application-config/nettest/mia').with(ensure: 'directory') }
      it { is_expected.to contain_file('/srv/application-config/nettest/mia/mia.toml').with(ensure: 'file', source: '/etc/mia-host.toml') }

      it {
        is_expected.to contain_dockerapp__run('nettest_api').with(
          volumes: [
            '/srv/application-config/nettest/api/certs/api.pfx:/netrisk/api.pfx',
            '/srv/application-config/nettest/api/certs/idp.pem:/netrisk/idp.pem',
            '/srv/application-config/nettest/api/certs/sp.pfx:/netrisk/sp.pfx',
            '/srv/application-log/nettest/api:/var/log/netrisk',
            '/srv/application-data/nettest/api/plugins:/netrisk/Plugins',
            '/srv/application-data/nettest/api/appdata:/var/netrisk',
            '/srv/application-config/nettest/mia/mia.toml:/etc/ferrogate/mia.toml:ro',
            'nettest-mia-api:/var/lib/ferrogate',
          ],
        )
      }
    end

    context 'embedded with mia_config_content' do
      let(:params) do
        base_params.merge(mia_mode: 'embedded', mia_config_content: "cmis_endpoint = \"https://cmis\"\n")
      end

      it { is_expected.to compile }
      it { is_expected.to contain_file('/srv/application-config/nettest/mia/mia.toml').with(ensure: 'file', content: "cmis_endpoint = \"https://cmis\"\n") }
    end

    context 'auto mode' do
      let(:params) { base_params.merge(mia_mode: 'auto', mia_cmis_endpoint: 'https://cmis:8443') }

      # auto may end up embedded, so the identity mount must be there; the
      # host socket is only mounted when host mode is asked for explicitly.
      it {
        is_expected.to contain_dockerapp__run('nettest_api').with(
          volumes: [
            '/srv/application-config/nettest/api/certs/api.pfx:/netrisk/api.pfx',
            '/srv/application-config/nettest/api/certs/idp.pem:/netrisk/idp.pem',
            '/srv/application-config/nettest/api/certs/sp.pfx:/netrisk/sp.pfx',
            '/srv/application-log/nettest/api:/var/log/netrisk',
            '/srv/application-data/nettest/api/plugins:/netrisk/Plugins',
            '/srv/application-data/nettest/api/appdata:/var/netrisk',
            'nettest-mia-api:/var/lib/ferrogate',
          ],
        )
      }
      it {
        is_expected.to contain_dockerapp__run('nettest_backgroundjobs').with(
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
            'MIA_MODE=auto',
            'MIA_REQUIRED=0',
            'FERROGATE_CMIS_ENDPOINT=https://cmis:8443',
          ],
        )
      }
    end

    context 'host mode' do
      let(:params) { base_params.merge(mia_mode: 'host', mia_required: true) }

      it { is_expected.to compile }

      # no agent in the container, hence no identity mount or volume
      it {
        is_expected.to contain_dockerapp__run('nettest_api').with(
          volumes: [
            '/srv/application-config/nettest/api/certs/api.pfx:/netrisk/api.pfx',
            '/srv/application-config/nettest/api/certs/idp.pem:/netrisk/idp.pem',
            '/srv/application-config/nettest/api/certs/sp.pfx:/netrisk/sp.pfx',
            '/srv/application-log/nettest/api:/var/log/netrisk',
            '/srv/application-data/nettest/api/plugins:/netrisk/Plugins',
            '/srv/application-data/nettest/api/appdata:/var/netrisk',
            '/run/ferrogate:/run/ferrogate-host:ro',
          ],
        )
      }

      it {
        is_expected.to contain_dockerapp__run('nettest_backgroundjobs').with(
          volumes: [
            '/srv/application-data/nettest/backups:/backups',
            '/srv/application-log/nettest/backgroundjobs:/var/log/netrisk',
            '/srv/application-data/nettest/backgroundjobs/appdata:/var/netrisk',
            '/run/ferrogate:/run/ferrogate-host:ro',
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
            'MIA_MODE=host',
            'MIA_REQUIRED=1',
          ],
        )
      }

      it { is_expected.not_to contain_docker_volume('nettest-mia-api') }
      it {
        is_expected.to contain_dockerapp__run('nettest_console')
          .with(volumes: [
            '/srv/application-data/nettest/backups:/backups',
            '/srv/application-log/nettest/console:/var/log/netrisk',
            '/srv/application-data/nettest/console/appdata:/var/netrisk',
          ], environments: [
            'FACTER_DBSERVER=testedb',
            'FACTER_DBUSER=netrisk',
            'FACTER_DBPORT=3306',
            'FACTER_DBPASSWORD=testepwd',
            'FACTER_DBSCHEMA=netrisk',
            'FACTER_SERVER_LOGGING=Information',
            'FACTER_NETRISK_USER=netrisk',
            'FACTER_NETRISK_UID=7070',
          ])
      }

      it {
        is_expected.to contain_dockerapp__run('nettest_website')
          .with(volumes: [
            '/srv/application-config/nettest/website/certs/website.pfx:/netrisk/website.pfx',
            '/srv/application-log/nettest/website:/var/log/netrisk',
          ], environments: [
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
          ])
      }
    end

    context 'host mode with a custom socket directory' do
      let(:params) { base_params.merge(mia_mode: 'host', mia_host_socket_dir: '/var/run/mia') }

      it {
        is_expected.to contain_dockerapp__run('nettest_api').with(
          volumes: [
            '/srv/application-config/nettest/api/certs/api.pfx:/netrisk/api.pfx',
            '/srv/application-config/nettest/api/certs/idp.pem:/netrisk/idp.pem',
            '/srv/application-config/nettest/api/certs/sp.pfx:/netrisk/sp.pfx',
            '/srv/application-log/nettest/api:/var/log/netrisk',
            '/srv/application-data/nettest/api/plugins:/netrisk/Plugins',
            '/srv/application-data/nettest/api/appdata:/var/netrisk',
            '/var/run/mia:/run/ferrogate-host:ro',
          ],
        )
      }
    end

    context 'with only the api enabled' do
      let(:params) { base_params.merge(mia_mode: 'embedded', mia_cmis_srv: 'x.example.com', enable_backgroundjobs: false) }

      it { is_expected.to contain_docker_volume('nettest-mia-api') }
      it { is_expected.not_to contain_docker_volume('nettest-mia-backgroundjobs') }
    end

    # Validation errors
    context 'embedded without endpoint, srv or mia.toml' do
      let(:params) { base_params.merge(mia_mode: 'embedded') }

      it { is_expected.to compile.and_raise_error(%r{mia_cmis_endpoint, mia_cmis_srv or a mia\.toml}) }
    end

    context 'auto without endpoint, srv or mia.toml' do
      let(:params) { base_params.merge(mia_mode: 'auto') }

      it { is_expected.to compile.and_raise_error(%r{mia_cmis_endpoint, mia_cmis_srv or a mia\.toml}) }
    end

    context 'host mode with an empty mia_host_socket_dir' do
      let(:params) { base_params.merge(mia_mode: 'host', mia_host_socket_dir: '') }

      it { is_expected.to compile.and_raise_error(%r{needs mia_host_socket_dir}) }
    end

    context 'host mode with a relative mia_host_socket_dir' do
      let(:params) { base_params.merge(mia_mode: 'host', mia_host_socket_dir: 'run/ferrogate') }

      it { is_expected.to compile.and_raise_error(%r{needs mia_host_socket_dir}) }
    end

    context 'mia_state_mode directory without mia_state_dir' do
      let(:params) { base_params.merge(mia_mode: 'embedded', mia_cmis_srv: 'x.example.com', mia_state_mode: 'directory') }

      it { is_expected.to compile.and_raise_error(%r{needs mia_state_dir}) }
    end

    context 'mia_config_source and mia_config_content together' do
      let(:params) { base_params.merge(mia_mode: 'embedded', mia_config_source: '/a.toml', mia_config_content: 'x = 1') }

      it { is_expected.to compile.and_raise_error(%r{mia_config_source and mia_config_content are mutually exclusive}) }
    end

    context 'mia_mode embedded with a version older than 2.50.0' do
      let(:params) { base_params.merge(version: '2.49.9', mia_mode: 'embedded', mia_cmis_srv: 'x.example.com') }

      it { is_expected.to compile.and_raise_error(%r{needs version >= 2\.50\.0}) }
    end

    context 'mia_mode host with a version older than 2.50.0' do
      let(:params) { base_params.merge(version: '1.4.1', mia_mode: 'host') }

      it { is_expected.to compile.and_raise_error(%r{needs version >= 2\.50\.0}) }
    end

    context 'mia_mode off with a version older than 2.50.0' do
      let(:params) { base_params.merge(version: '1.4.1') }

      it { is_expected.to compile }
    end

    context 'mia_mode host with version latest' do
      let(:params) { base_params.merge(version: 'latest', mia_mode: 'host') }

      it { is_expected.to compile }
    end

    context 'mia_mode host with a tag that is not a version' do
      let(:params) { base_params.merge(version: 'nightly', mia_mode: 'host') }

      it { is_expected.to compile.and_raise_error(%r{cannot be compared}) }
    end

    context 'mia_env with a key that is not FERROGATE_*' do
      let(:params) { base_params.merge(mia_mode: 'host', mia_env: { 'MIA_MODE' => 'off' }) }

      it { is_expected.to compile.and_raise_error(%r{must look like FERROGATE_\*}) }
    end

    context 'mia_env with a key that has a dedicated parameter' do
      let(:params) { base_params.merge(mia_mode: 'host', mia_env: { 'FERROGATE_CMIS_SPKI_PIN' => 'x' }) }

      it { is_expected.to compile.and_raise_error(%r{has a dedicated parameter}) }
    end
  end
end
