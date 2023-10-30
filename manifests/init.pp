# @summary This is the main class wich will make netrisk run with all components
# Makes netrisk run
#
# @param service_name
#   The name of the service, directories and base containers
#
# @param version
#   The version to be installed
#
# @param api_server
#   The server from wich the api should be called
#
# @param api_protocol
#   The protocol api will use [http or https (default)]
#
# @param api_port
#   The port to use with the api
#
# @param website_server
#   The server from wich the website should be called
#
# @param website_protocol
#   The protocol website will use [http or https (default)]
#
# @param website_port
#   The port to use with the website
#
# @param db_server
#   The server running the dbms (only mariadb is supported as right now)
#
# @param db_port
#   The port dbms is running
#
# @param db_schema
#   The schema used on the dbms
#
# @param db_user
#   The user used on the dbms
#
# @param db_password
#   The password used on the dbms
#
# @param api_ssl_cert_file
#   The certificate file path
#
# @param api_ssl_cert_pwd
#   The password of the ssl file
#
# @param website_ssl_cert_file
#   The certificate file path for the website 
#
# @param website_ssl_cert_pwd
#   The password of the ssl file fro the website
#
# @param logging
#   The log level to be used on the application
#
# @param email_from
#   The email from to use on sent messages
#
# @param email_server
#   The smtp email server (no authentication is supported right now)
#
# @param email_port
#   The smtp email port (no ssl is supported right now)
#
# @param enable_api
#   If disabled the api container will not be run
#
# @param enable_website
#   If disabled the website container will not be run
#
# @param enable_console
#   If disabled the console container will not be run
#
# @param enable_saml
#   If we should use saml configs for login
#
# @param user
#   The user used to run the processes
#
# @enable_backgroundjobs
#   If we need to use background jobs
#
# @param uid
#   The uid of the user used ot run the processes
#
# @example
#   include dockerapp_netrisk
class dockerapp_netrisk (
  String  $service_name = 'netrisk',
  String  $version = 'latest',
  String  $api_server = $fqdn,
  String  $api_protocol = 'https',
  Integer $api_port = 5443,
  Integer $website_port = 443,
  String  $website_protocol = 'https',
  String  $website_server = $fqdn,
  String  $db_server = '-',
  Integer $db_port = 3306,
  String  $db_schema = 'netrisk',
  String  $db_user = 'netrisk',
  String $db_password = '-',
  String $api_ssl_cert_file = '-',
  String $api_ssl_cert_pwd = '-',
  String $website_ssl_cert_file = '-',
  String $website_ssl_cert_pwd = '-',
  String $logging = 'Information',
  String $email_from = 'netrisk@mail.com',
  String $email_server = 'localhost',
  Integer $email_port = 25,
  Boolean $enable_api = true,
  Boolean $enable_website = true,
  Boolean $enable_console = true,
  Boolean $enable_backgroundjobs = true,
  Boolean $enable_saml = false,
  String $user = 'netrisk',
  Integer $uid = 7070,
  String $idp_entity_id = '',
  String $idp_sso_service = '',
  String $idp_ssout_service = '',
  String $idp_artifact_resolve_srvc = '',
  String $idp_certificate = '',
  String $sp_certificate_file = '',
  String $sp_certificate_pwd = '',
) {
  include dockerapp::params
  include dockerapp::basedirs

  #include dockerapp::params

  if !defined(Class['dockerapp']) {
    class { 'dockerapp':
      manage_docker => false,
    }
  }

  if !defined(Class['docker']) {
    class { 'docker':
      manage_service              => false,
      use_upstream_package_source => false,
      manage_package              => false,
    }
  }

  $base_app_config = $dockerapp::params::config_dir
  $base_app_home = $dockerapp::params::data_dir
  $base_app_scripts = $dockerapp::params::scripts_dir
  $base_app_logs = $dockerapp::params::log_dir

  $conf_homedir = "${base_app_home}/${service_name}"
  $conf_homedir_backups = "${base_app_home}/${service_name}/backups"
  $conf_homedir_website = "${base_app_home}/${service_name}/website"
  $conf_homedir_api = "${base_app_home}/${service_name}/api"
  $conf_homedir_backgroundjobs = "${base_app_home}/${service_name}/backgroundjobs"
  $conf_configdir = "${base_app_config}/${service_name}"
  $conf_configdir_website = "${base_app_config}/${service_name}/website"
  $conf_configdir_api = "${base_app_config}/${service_name}/api"
  $conf_configdir_backgroundjobs = "${base_app_config}/${service_name}/backgroundjobs"
  $conf_configdir_configurations = "${base_app_config}/${service_name}/configurations"
  $conf_configdir_ssl = "${base_app_config}/${service_name}/ssl"
  $conf_scriptsdir = "${base_app_scripts}/${service_name}"
  $conf_logsdir = "${base_app_logs}/${service_name}"
  $conf_logsdir_website = "${base_app_logs}/${service_name}/website"
  $conf_logsdir_api = "${base_app_logs}/${service_name}/api"
  $conf_logsdir_backgroundjobs = "${base_app_logs}/${service_name}/backgroundjobs"

  $image_name_api = "ffquintella/netrisk-api:${version}"
  $image_name_website = "ffquintella/netrisk-website:${version}"
  $image_name_console = "ffquintella/netrisk-console:${version}"
  $image_name_backgroundjobs = "ffquintella/netrisk-backgroundjobs:${version}"

  if !defined(User[$user]) {
    user { $user:
      home    => $conf_configdir,
      shell   => '/bin/bash',
      uid     => $uid,
      require => File[$conf_configdir],
    }
  }

  if ! defined(File[$conf_homedir]) {
    file { $conf_homedir:
      ensure  => directory,
      require => File[$base_app_home],
    }
  }
  if ! defined(File[$conf_homedir_backups]) {
    file { $conf_homedir_backups:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_homedir],User[$user]],
    }
  }
  if ! defined(File[$conf_homedir_website]) {
    file { $conf_homedir_website:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_homedir],User[$user]],
    }
  }
  if ! defined(File[$conf_homedir_api]) {
    file { $conf_homedir_api:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_homedir],User[$user]],
    }
  }
  if ! defined(File[$conf_homedir_backgroundjobs]) {
    file { $conf_homedir_backgroundjobs:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_homedir],User[$user]],
    }
  }

  if ! defined(File[$conf_configdir]) {
    file { $conf_configdir:
      ensure  => directory,
      require => File[$base_app_config],
    }
  }

  if ! defined(File[$conf_configdir_website]) {
    file { $conf_configdir_website:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_configdir],User[$user]],
    }
  }
  if ! defined(File[$conf_configdir_api]) {
    file { $conf_configdir_api:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_configdir],User[$user]],
    }
  }
  if ! defined(File[$conf_configdir_backgroundjobs]) {
    file { $conf_configdir_backgroundjobs:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_configdir],User[$user]],
    }
  }
  if ! defined(File[$conf_configdir_configurations]) {
    file { $conf_configdir_configurations:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_configdir],User[$user]],
    }
  }
  if ! defined(File[$conf_configdir_ssl]) {
    file { $conf_configdir_ssl:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_configdir],User[$user]],
    }
  }
  if ! defined(File[$conf_scriptsdir]) {
    file { $conf_scriptsdir:
      ensure  => directory,
      require => File[$base_app_scripts],
    }
  }
  if ! defined(File[$conf_logsdir]) {
    file { $conf_logsdir:
      ensure  => directory,
      require => File[$base_app_logs],
    }
  }
  if ! defined(File[$conf_logsdir_website]) {
    file { $conf_logsdir_website:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_logsdir],User[$user]],
    }
  }
  if ! defined(File[$conf_logsdir_api]) {
    file { $conf_logsdir_api:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_logsdir],User[$user]],
    }
  }
  if ! defined(File[$conf_logsdir_backgroundjobs]) {
    file { $conf_logsdir_backgroundjobs:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_logsdir],User[$user]],
    }
  }

  if $db_server == '-' { fail('db_server cannot be empty') }
  if $db_password == '-' { fail('db_password is mandatory') }
  if $api_ssl_cert_file == '-' { fail('api_ssl_cert_file is mandatory') }
  if $api_ssl_cert_pwd == '-' { fail('api_ssl_cert_pwd is mandatory') }
  if $website_ssl_cert_file == '-' { fail('website_ssl_cert_file is mandatory') }
  if $website_ssl_cert_pwd == '-' { fail('website_ssl_cert_pwd is mandatory') }

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
    'FACTER_SERVER_CERTIFICATE_FILE=/netrisk/api.pfx',
    "FACTER_SERVER_CERTIFICATE_PWD=${api_ssl_cert_pwd}",
    "FACTER_WEBSITE_PROTOCOL=${website_protocol}",
    "FACTER_WEBSITE_HOST=${website_server}",
    "FACTER_WEBSITE_PORT=${website_port}",
    "FACTER_NETRISK_USER=${user}",
    "FACTER_NETRISK_UID=${uid}",
    'FACTER_IDP_NAME=SAML',
    "FACTER_IDP_ENTITY_ID=${idp_entity_id}",
    "FACTER_IDP_SSO_SERVICE=${idp_sso_service}",
    "FACTER_IDP_SSOUT_SERVICE=${idp_ssout_service}",
    "FACTER_IDP_ARTIFACT_RESOLVE_SRVC=${idp_artifact_resolve_srvc}",
    "FACTER_IDP_CERTIFICATE=${idp_certificate}",
    "FACTER_SP_CERTIFICATE_FILE=${sp_certificate_file}",
    "FACTER_SP_CERTIFICATE_PWD=${sp_certificate_pwd}",
  ]

  file { "${conf_configdir_api}/certs":
    ensure  => directory,
    require => File[$conf_configdir_api],
  }
  -> file { "${conf_configdir_api}/certs/api.pfx":
    ensure => file,
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
      "${conf_logsdir_api}:/var/log/netrisk",
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

  file { "${conf_configdir_website}/certs":
    ensure  => directory,
    require => File[$conf_configdir_website],
  }
  -> file { "${conf_configdir_website}/certs/website.pfx":
    ensure => file,
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
    'FACTER_SERVER_CERTIFICATE_FILE=/netrisk/website.pfx',
    "FACTER_SERVER_CERTIFICATE_PWD=${website_ssl_cert_pwd}",
    "FACTER_WEBSITE_PROTOCOL=${website_protocol}",
    "FACTER_WEBSITE_HOST=${website_server}",
    "FACTER_WEBSITE_PORT=${website_port}",
    "FACTER_SERVER_HTTPS_PORT=${website_port}",
    "FACTER_ENABLE_SAML=${enable_saml}",
    "FACTER_NETRISK_USER=${user}",
    "FACTER_NETRISK_UID=${uid}",
  ]

  if $enable_website == true {
    $website_service_name = "${service_name}_website"
    $website_ports = ["${website_port}:${website_port}"]

    $volumes_website = [
      "${conf_configdir_website}/certs/website.pfx:/netrisk/website.pfx",
      "${conf_logsdir_website}:/var/log/netrisk",
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
    "FACTER_NETRISK_USER=${user}",
    "FACTER_NETRISK_UID=${uid}",
  ]

  if $enable_console == true {
    $console_service_name = "${service_name}_console"

    file { '/usr/local/bin/netrisk-console':
      ensure  => file,
      owner   => $user,
      mode    => '0750',
      content => epp('dockerapp_netrisk/netrisk-console.epp', {
          'service_name' => $console_service_name
    }) }

    dockerapp::run { $console_service_name:
      image        => $image_name_console,
      environments => $envs_console,
      net          => $network_name,
    }
  }

  $envs_backgroundjobs = [
    "FACTER_NETRISK_URL=${api_protocol}//${api_server}:${api_port}",
    "FACTER_DBSERVER=${db_server}",
    "FACTER_DBUSER=${db_user}",
    "FACTER_DBPORT=${db_port}",
    "FACTER_DBPASSWORD=${db_password}",
    "FACTER_DBSCHEMA=${db_schema}",
    "FACTER_SERVER_LOGGING=${logging}",
    "FACTER_NETRISK_USER=${user}",
    "FACTER_NETRISK_UID=${uid}",
  ]

  if $enable_backgroundjobs == true {
    $backgroundjobs_service_name = "${service_name}_backgroundjobs"

    dockerapp::run { $backgroundjobs_service_name:
      image        => $image_name_backgroundjobs,
      environments => $envs_backgroundjobs,
      net          => $network_name,
    }
  }
}
