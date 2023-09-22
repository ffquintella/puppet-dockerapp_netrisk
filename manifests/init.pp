# @summary This is the main class wich will make netrisk run with all components
#
# Makes netrisk run
#
# @parameters
#
# [*service_name*]
#   The name of the service, directories and base containers
#
# [*version*]
#   The version to be installed
#
# [*api_server*]
#   The server from wich the api should be called
#
# [*api_protocol*]
#   The protocol api will use [http or https (default)]
#
# [*api_port*]
#   The port to use with the api
#
# [*website_server*]
#   The server from wich the website should be called
#
# [*website_protocol*]
#   The protocol website will use [http or https (default)]
#
# [*website_port*]
#   The port to use with the website
#
# [*db_server*]
#   The server running the dbms (only mariadb is supported as right now)
#
# [*db_port*]
#   The port dbms is running
#
# [*db_schema*]
#   The schema used on the dbms
#
# [*db_user*]
#   The user used on the dbms
#
# [*db_password*]
#   The password used on the dbms
#
# [*ssl_cert_file*]
#   The certificate file path
#
# [*db_password*]
#   The certificate file password
#
# [*logging*]
#   The log level to be used on the application
#
# [*email_from*]
#   The email from to use on sent messages
#
# [*email_server*]
#   The smtp email server (no authentication is supported right now)
#
# [*email_port*]
#   The smtp email port (no ssl is supported right now)
#
# [*enable_api*]
#   If disabled the api container will not be run
#
# [*enable_website*]
#   If disabled the website container will not be run
#
# [*enable_console*]
#   If disabled the console container will not be run
#
# [*enable_saml*]
#   If we should use saml configs for login
#
# @example
#   include dockerapp_netrisk
class dockerapp_netrisk(
  $service_name = 'netrisk',
  $version = 'latest',
  $api_server = $::fqdn,
  $api_protocol = 'https',
  $api_port = '5443',
  $website_port = '443',
  $website_protocol = 'https',
  $website_server = $::fqdn,
  $db_server = '',
  $db_port = '3306',
  $db_schema = 'netrisk',
  $db_user = 'netrisk',
  $db_password = '',
  $api_ssl_cert_file = '',
  $api_ssl_cert_pwd = '',
  $website_ssl_cert_file = '',
  $website_ssl_cert_pwd = '',
  $logging = 'Information',
  $email_from = 'netrisk@mail.com',
  $email_server = 'localhost',
  $email_port = 25,
  $enable_api = true,
  $enable_website = true,
  $enable_console = true,
  $enable_saml = false
) inherits dockerapp::params {

include dockerapp::basedirs

#include dockerapp::params

  if !defined(Class["::dockerapp"]){
    class {"dockerapp":
      manage_docker => false
    }
  }

  if !defined(Class['::docker']){
    class {'docker':
      manage_service              => false,
      use_upstream_package_source => false,
      manage_package              => false,
    }
  }


    $base_app_config = $::dockerapp::params::config_dir
    $base_app_home = $::dockerapp::params::data_dir
    $base_app_scripts = $::dockerapp::params::scripts_dir
    $base_app_logs = $::dockerapp::params::log_dir


    $conf_homedir = "${base_app_home}/${service_name}"
    $conf_homedir_backups = "${base_app_home}/${service_name}/backups"
    $conf_homedir_website = "${base_app_home}/${service_name}/website"
    $conf_homedir_api = "${base_app_home}/${service_name}/api"
    $conf_configdir = "${base_app_config}/${service_name}"
    $conf_configdir_website = "${base_app_config}/${service_name}/website"
    $conf_configdir_api = "${base_app_config}/${service_name}/api"
    $conf_configdir_configurations = "${base_app_config}/${service_name}/configurations"
    $conf_configdir_ssl = "${base_app_config}/${service_name}/ssl"
    $conf_scriptsdir = "${base_app_scripts}/${service_name}"
    $conf_logsdir = "${base_app_logs}/${service_name}"
    $conf_logsdir_website = "${base_app_logs}/${service_name}/website"
    $conf_logsdir_api = "${base_app_logs}/${service_name}/api"


    $image_name_api = "ffquintella/netrisk-api:${version}"
    $image_name_website = "ffquintella/netrisk-website:${version}"
    $image_name_console = "ffquintella/netrisk-console:${version}"


    if ! defined(File[$conf_homedir]) {
      file{ $conf_homedir:
        ensure  => directory,
        require => File[$base_app_home],
      }
    }
    if ! defined(File[$conf_homedir_backups]) {
      file{ $conf_homedir_backups:
        ensure  => directory,
        owner   => 33,
        group   => 33,
        require => File[$conf_homedir],
      }
    }
    if ! defined(File[$conf_homedir_website]) {
      file{ $conf_homedir_website:
        ensure  => directory,
        owner   => 33,
        group   => 33,
        require => File[$conf_homedir],
      }
    }
    if ! defined(File[$conf_homedir_api]) {
      file{ $conf_homedir_api:
        ensure  => directory,
        owner   => 33,
        group   => 33,
        require => File[$conf_homedir],
      }
    }

    if ! defined(File[$conf_configdir]) {
      file{ $conf_configdir:
        ensure  => directory,
        require => File[$base_app_config],
      }
    }
    if ! defined(File[$conf_configdir_website]) {
      file{ $conf_configdir_website:
        ensure  => directory,
        owner   => 33,
        group   => 33,
        require => File[$conf_configdir],
      }
    }
    if ! defined(File[$conf_configdir_api]) {
      file{ $conf_configdir_api:
        ensure  => directory,
        owner   => 33,
        group   => 33,
        require => File[$conf_configdir],
      }
    }
    if ! defined(File[$conf_configdir_configurations]) {
      file{ $conf_configdir_configurations:
        ensure  => directory,
        owner   => 33,
        group   => 33,
        require => File[$conf_configdir],
      }
    }
    if ! defined(File[$conf_configdir_ssl]) {
      file{ $conf_configdir_ssl:
        ensure  => directory,
        owner   => 33,
        group   => 33,
        require => File[$conf_configdir],
      }
    }
    if ! defined(File[$conf_scriptsdir]) {
      file{ $conf_scriptsdir:
        ensure  => directory,
        require => File[$base_app_scripts],
      }
    }
    if ! defined(File[$conf_logsdir]) {
      file{ $conf_logsdir:
        ensure  => directory,
        require => File[$base_app_logs],
      }
    }
    if ! defined(File[$conf_logsdir_website]) {
      file{ $conf_logsdir_website:
        ensure  => directory,
        owner   => 33,
        group   => 33,
        require => File[$conf_logsdir],
      }
    }
    if ! defined(File[$conf_logsdir_api]) {
      file{ $conf_logsdir_api:
        ensure  => directory,
        owner   => 33,
        group   => 33,
        require => File[$conf_logsdir],
      }
    }

  if $db_server == '' { fail('db_server cannot be empty') }
  if $db_password == '' { fail('db_password is mandatory') }
  if $api_ssl_cert_file == '' { fail('api_ssl_cert_file is mandatory') }
  if $api_ssl_cert_pwd == '' { fail('api_ssl_cert_pwd is mandatory') }
  if $website_ssl_cert_file == '' { fail('website_ssl_cert_file is mandatory') }
  if $website_ssl_cert_pwd == '' { fail('website_ssl_cert_pwd is mandatory') }

  #API CONFIGS
  $envs_api = [
    "FACTER_ENABLE_SAML=${enable_saml}",
    "FACTER_DBSERVER=${db_server}",
    "FACTER_DBUSER=${db_user}",
    "FACTER_DBPORT=${db_port}",
    "FACTER_DBPASSWORD=${db_password}",
    "FACTER_DBSCHEMA=${db_schema}",
    "FACTER_NETRISK_URL=${api_protocol}//${api_server}:${api_port}",
    "FACTER_SERVER_LOGGING=${logging}",
    "FACTER_EMAIL_FROM=${email_from}",
    "FACTER_EMAIL_SERVER=${email_server}",
    "FACTER_EMAIL_PORT=${email_port}",
    "FACTER_SERVER_CERTIFICATE_FILE=${api_ssl_cert_file}",
    "FACTER_SERVER_CERTIFICATE_PWD=${api_ssl_cert_pwd}",
    "FACTER_WEBSITE_PROTOCOL=${website_protocol}",
    "FACTER_WEBSITE_HOST=${website_server}",
    "FACTER_WEBSITE_PORT=${website_port}",
    "FACTER_ENABLE_SAML=${enable_saml}",
  ]

  file{"${conf_configdir_api}/certs":
    ensure  => directory,
    require => File[$conf_configdir_api],
  }
  -> file{"${conf_configdir_api}/certs/api.pfx":
    ensure => present,
    source => $api_ssl_cert_file,
  }


  $network_name = "${service_name}-net"

  docker_network { $network_name:
    ensure   => present,
  }


  if $enable_api == true {

    $api_service_name = "${service_name}_api"

    $api_ports = ["${api_port}:5443"]

    $volumes_api = [
      "${conf_configdir_api}/certs/api.pfx:/netrisk/api.pfx",
    ]

    dockerapp::run { $api_service_name:
      image        => $image_name_api,
      ports        => $api_ports,
      volumes      => $volumes_api,
      environments => $envs_api,
      net          => $network_name,
      require      => [File["${conf_configdir_api}/certs/api.pfx"]],
    }
  }


  #WEBSITE CONFIGS

  file{"${conf_configdir_website}/certs":
    ensure  => directory,
    require => File[$conf_configdir_website],
  }
  -> file{"${conf_configdir_website}/certs/website.pfx":
    ensure => present,
    source => $website_ssl_cert_file,
  }

  $envs_website = [
    "FACTER_DBSERVER=${db_server}",
    "FACTER_DBUSER=${db_user}",
    "FACTER_DBPORT=${db_port}",
    "FACTER_DBPASSWORD=${db_password}",
    "FACTER_DBSCHEMA=${db_schema}",
    "FACTER_NETRISK_URL=${api_protocol}//${api_server}:${api_port}",
    "FACTER_SERVER_LOGGING=${logging}",
    "FACTER_EMAIL_FROM=${email_from}",
    "FACTER_EMAIL_SERVER=${email_server}",
    "FACTER_EMAIL_PORT=${email_port}",
    "FACTER_SERVER_CERTIFICATE_FILE=${website_ssl_cert_file}",
    "FACTER_SERVER_CERTIFICATE_PWD=${website_ssl_cert_pwd}",
    "FACTER_WEBSITE_PROTOCOL=${website_protocol}",
    "FACTER_WEBSITE_HOST=${website_server}",
    "FACTER_WEBSITE_PORT=${website_port}",
    "FACTER_ENABLE_SAML=${enable_saml}",
  ]


  if $enable_website == true {

    $website_service_name = "${service_name}_website"

    $website_ports = ["${website_port}:6443"]

    $volumes_website = [
      "${conf_configdir_website}/certs/website.pfx:/netrisk/website.pfx",
    ]

    dockerapp::run { $website_service_name:
      image        => $image_name_website,
      ports        => $website_ports,
      volumes      => $volumes_website,
      environments => $envs_website,
      net          => $network_name,
      require      => [File["${conf_configdir_website}/certs/website.pfx"]],
    }
  }

  $envs_console = [
    "FACTER_DBSERVER=${db_server}",
    "FACTER_DBUSER=${db_user}",
    "FACTER_DBPORT=${db_port}",
    "FACTER_DBPASSWORD=${db_password}",
    "FACTER_DBSCHEMA=${db_schema}",
    "FACTER_SERVER_LOGGING=${logging}",
  ]


  if $enable_console == true {

    $console_service_name = "${service_name}_console"


    dockerapp::run { $console_service_name:
      image        => $image_name_console,
      environments => $envs_console,
      net          => $network_name,
    }
  }

}
