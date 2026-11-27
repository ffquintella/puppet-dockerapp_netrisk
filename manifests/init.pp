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
# @param api_ssl_cert_base64
#   Base64 content of the API PFX. When set it is decoded and written to the
#   certs dir, and api_ssl_cert_file is no longer required.
#
# @param api_ssl_cert_pwd
#   The password of the ssl file
#
# @param website_ssl_cert_file
#   The certificate file path for the website 
#
# @param website_ssl_cert_base64
#   Base64 content of the website PFX. When set it is decoded and written to
#   the certs dir, and website_ssl_cert_file is no longer required.
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
# @param secret_master_key
#   The master key used by the application to encrypt stored integration
#   credentials (webhooks, api tokens, oidc secrets, biometric templates).
#   It must be the base64 encoding of 32 random bytes, which you can generate
#   with `openssl rand -base64 32`. When left undef the host generates its own
#   key and persists it on the application data volume mounted at /var/netrisk.
#
# @param mia_mode
#   FerroGate MIA (Machine Identity Agent) mode for the api and backgroundjobs
#   containers (never console or website). 'off' (default) leaves the
#   containers exactly as before. 'embedded' runs an agent inside the container
#   with its own identity; 'host' uses the MIA of the Docker host through its
#   socket; 'auto' lets the image entrypoint choose (host if the socket is
#   mounted, else embedded if a CMIS endpoint exists, else off). Anything other
#   than 'off' needs version >= 2.50.0 (or 'latest'). Because the socket mount
#   is only added for 'host', use 'host' explicitly to reach the host MIA.
#
# @param mia_required
#   When true the container aborts if the agent or socket is unavailable
#   (MIA_REQUIRED=1).
#
# @param mia_cmis_endpoint
#   FERROGATE_CMIS_ENDPOINT. Embedded/auto need this, mia_cmis_srv or a mia.toml.
#
# @param mia_cmis_srv
#   FERROGATE_CMIS_SRV, a DNS SRV name used to discover the CMIS.
#
# @param mia_cmis_spki_pin
#   FERROGATE_CMIS_SPKI_PIN. The pin is not a secret.
#
# @param mia_allowlist_key
#   FERROGATE_ALLOWLIST_KEY.
#
# @param mia_env
#   Any other FERROGATE_* variable to hand to the agent as is. Values may be
#   Sensitive. Like every container environment variable they are visible in
#   `docker inspect` (the same exposure as db_password), so keep real
#   credentials out of it. The keys that have a dedicated parameter are
#   rejected here.
#
# @param mia_config_source
#   Puppet file source (e.g. a path on the node or a puppet:/// URL) of a
#   mia.toml. It is written to a host directory and mounted read-only at
#   /etc/ferrogate/mia.toml. Mutually exclusive with mia_config_content.
#
# @param mia_config_content
#   Content of the mia.toml, as an alternative to mia_config_source.
#
# @param mia_state_mode
#   Where the machine identity (/var/lib/ferrogate) lives: 'volume' (default,
#   a named Docker volume) or 'directory' (a bind mount of mia_state_dir).
#   Each container gets its own identity, so the volume or directory name gets
#   an -api / -backgroundjobs (or /api, /backgroundjobs) suffix. Always mounted
#   when the mode is embedded or auto.
#
# @param mia_state_volume
#   Base name of the identity volumes. Defaults to "<service_name>-mia".
#
# @param mia_state_dir
#   Host directory holding the identity when mia_state_mode is 'directory'.
#   Required in that case. Subdirectories are created mode 0700; the image
#   entrypoint chowns them to the agent account, so the owner is not managed.
#
# @param mia_host_socket_dir
#   Host directory with the MIA socket, mounted read-only at
#   /run/ferrogate-host in 'host' mode. It is the directory, not the socket,
#   that is mounted, because the host MIA recreates the socket on restart.
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
  Sensitive[String] $db_password = Sensitive('-'),
  String $api_ssl_cert_file = '-',
  Optional[String] $api_ssl_cert_base64 = undef,
  Sensitive[String] $api_ssl_cert_pwd = Sensitive('-'),
  String $website_ssl_cert_file = '-',
  Optional[String] $website_ssl_cert_base64 = undef,
  Sensitive[String] $website_ssl_cert_pwd = Sensitive('-'),
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
  Optional[String] $sp_certificate_base64 = undef,
  Sensitive[String] $sp_certificate_pwd = Sensitive(''),
  Optional[Sensitive[String[1]]] $secret_master_key = undef,
  Enum['auto','embedded','host','off'] $mia_mode = 'off',
  Boolean $mia_required = false,
  Optional[String[1]] $mia_cmis_endpoint = undef,
  Optional[String[1]] $mia_cmis_srv = undef,
  Optional[String[1]] $mia_cmis_spki_pin = undef,
  Optional[String[1]] $mia_allowlist_key = undef,
  Hash[String, Variant[String, Sensitive[String]]] $mia_env = {},
  Optional[String[1]] $mia_config_source = undef,
  Optional[String[1]] $mia_config_content = undef,
  Enum['volume','directory'] $mia_state_mode = 'volume',
  Optional[String[1]] $mia_state_volume = undef,
  Optional[String[1]] $mia_state_dir = undef,
  String $mia_host_socket_dir = '/run/ferrogate',
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
  $conf_homedir_api_plugins = "${conf_homedir_api}/plugins"
  $conf_homedir_api_appdata = "${conf_homedir_api}/appdata"
  $conf_homedir_console = "${base_app_home}/${service_name}/console"
  $conf_homedir_console_appdata = "${conf_homedir_console}/appdata"
  $conf_homedir_backgroundjobs = "${base_app_home}/${service_name}/backgroundjobs"
  $conf_homedir_backgroundjobs_appdata = "${conf_homedir_backgroundjobs}/appdata"
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
  $conf_logsdir_console = "${base_app_logs}/${service_name}/console"
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
  if ! defined(File[$conf_homedir_api_plugins]) {
    file { $conf_homedir_api_plugins:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_homedir_api],User[$user]],
    }
  }
  if ! defined(File[$conf_homedir_api_appdata]) {
    file { $conf_homedir_api_appdata:
      ensure  => directory,
      owner   => $user,
      mode    => '0700',
      require => [File[$conf_homedir_api],User[$user]],
    }
  }
  if ! defined(File[$conf_homedir_console]) {
    file { $conf_homedir_console:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_homedir],User[$user]],
    }
  }
  if ! defined(File[$conf_homedir_console_appdata]) {
    file { $conf_homedir_console_appdata:
      ensure  => directory,
      owner   => $user,
      mode    => '0700',
      require => [File[$conf_homedir_console],User[$user]],
    }
  }
  if ! defined(File[$conf_homedir_backgroundjobs]) {
    file { $conf_homedir_backgroundjobs:
      ensure  => directory,
      owner   => $user,
      require => [File[$conf_homedir],User[$user]],
    }
  }
  if ! defined(File[$conf_homedir_backgroundjobs_appdata]) {
    file { $conf_homedir_backgroundjobs_appdata:
      ensure  => directory,
      owner   => $user,
      mode    => '0700',
      require => [File[$conf_homedir_backgroundjobs],User[$user]],
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
  if ! defined(File[$conf_logsdir_console]) {
    file { $conf_logsdir_console:
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
  if $db_password.unwrap == '-' { fail('db_password is mandatory') }
  if $api_ssl_cert_file == '-' and $api_ssl_cert_base64 == undef { fail('api_ssl_cert_file is mandatory') }
  if $api_ssl_cert_pwd.unwrap == '-' { fail('api_ssl_cert_pwd is mandatory') }
  if $website_ssl_cert_file == '-' and $website_ssl_cert_base64 == undef { fail('website_ssl_cert_file is mandatory') }
  if $website_ssl_cert_pwd.unwrap == '-' { fail('website_ssl_cert_pwd is mandatory') }

  # The master key encrypts every stored integration credential. A key of the
  # wrong length is only noticed once the application refuses to decrypt them,
  # so reject it here instead of passing it through to the container.
  if $secret_master_key =~ NotUndef {
    $master_key_plain = $secret_master_key.unwrap
    if $master_key_plain !~ /\A[A-Za-z0-9+\/]{43}=?\z/ {
      fail("secret_master_key must be the base64 encoding of exactly 32 bytes; generate one with 'openssl rand -base64 32'")
    }
    $master_key_env = ["FACTER_SECRET_MASTER_KEY=${master_key_plain}"]
  } else {
    $master_key_env = []
  }

  # FerroGate MIA (api and backgroundjobs only). With mia_mode 'off' nothing
  # below adds a volume, a variable or a resource.
  $mia_enabled = $mia_mode != 'off'
  $mia_has_config = $mia_config_source =~ NotUndef or $mia_config_content =~ NotUndef
  $mia_embedded = $mia_mode in ['embedded', 'auto']
  $mia_host = $mia_mode == 'host'
  $mia_dedicated_keys = ['FERROGATE_CMIS_ENDPOINT', 'FERROGATE_CMIS_SRV', 'FERROGATE_CMIS_SPKI_PIN', 'FERROGATE_ALLOWLIST_KEY']
  $conf_configdir_mia = "${conf_configdir}/mia"
  $mia_state_volume_base = $mia_state_volume ? { undef => "${service_name}-mia", default => $mia_state_volume }

  if $mia_config_source =~ NotUndef and $mia_config_content =~ NotUndef {
    fail('mia_config_source and mia_config_content are mutually exclusive')
  }
  $mia_env.each |$key, $value| {
    if $key !~ /\AFERROGATE_[A-Z0-9_]+\z/ {
      fail("mia_env key '${key}' must look like FERROGATE_*")
    }
    if $key in $mia_dedicated_keys {
      fail("mia_env key '${key}' has a dedicated parameter; use that instead")
    }
  }

  if $mia_enabled {
    if $version != 'latest' {
      # Pure regex on purpose: too old is 0.x, 1.x and 2.0 to 2.49.
      if $version !~ /\Av?\d+\.\d+/ {
        fail("mia_mode '${mia_mode}' needs an image version >= 2.50.0, but version '${version}' cannot be compared; use a numeric tag or 'latest'")
      }
      if $version =~ /\Av?(?:[01]\.\d+|2\.(?:\d|[1-4]\d)(?:[.+-]|\z))/ {
        fail("mia_mode '${mia_mode}' needs version >= 2.50.0, the first image with the FerroGate MIA client (got '${version}')")
      }
    }
    if $mia_embedded and $mia_cmis_endpoint =~ Undef and $mia_cmis_srv =~ Undef and !$mia_has_config {
      fail("mia_mode '${mia_mode}' needs mia_cmis_endpoint, mia_cmis_srv or a mia.toml (mia_config_source / mia_config_content)")
    }
    if $mia_host and $mia_host_socket_dir !~ /\A\/.+/ {
      fail("mia_mode 'host' needs mia_host_socket_dir set to the absolute path of the host MIA socket directory")
    }
    if $mia_state_mode == 'directory' and $mia_state_dir =~ Undef {
      fail("mia_state_mode 'directory' needs mia_state_dir")
    }
  }

  if $mia_enabled {
    $mia_required_flag = $mia_required ? { true => '1', default => '0' }
    $mia_dedicated_env = [
      $mia_cmis_endpoint ? { undef => [], default => ["FERROGATE_CMIS_ENDPOINT=${mia_cmis_endpoint}"] },
      $mia_cmis_srv ? { undef => [], default => ["FERROGATE_CMIS_SRV=${mia_cmis_srv}"] },
      $mia_cmis_spki_pin ? { undef => [], default => ["FERROGATE_CMIS_SPKI_PIN=${mia_cmis_spki_pin}"] },
      $mia_allowlist_key ? { undef => [], default => ["FERROGATE_ALLOWLIST_KEY=${mia_allowlist_key}"] },
    ].flatten
    $mia_extra_env = $mia_env.keys.sort.map |$key| {
      $value = $mia_env[$key]
      $plain = $value ? { Sensitive => $value.unwrap, default => $value }
      "${key}=${plain}"
    }
    $mia_envs = ["MIA_MODE=${mia_mode}", "MIA_REQUIRED=${mia_required_flag}"] + $mia_dedicated_env + $mia_extra_env

    $mia_config_volumes = $mia_has_config ? {
      true    => ["${conf_configdir_mia}/mia.toml:/etc/ferrogate/mia.toml:ro"],
      default => [],
    }
    $mia_socket_volumes = $mia_host ? {
      true    => ["${mia_host_socket_dir}:/run/ferrogate-host:ro"],
      default => [],
    }
    # The identity mount is what keeps the host key across container
    # recreation; the entrypoint refuses to start an embedded agent without it.
    if $mia_embedded {
      $mia_state_name_api = $mia_state_mode ? {
        'directory' => "${mia_state_dir}/api",
        default     => "${mia_state_volume_base}-api",
      }
      $mia_state_name_backgroundjobs = $mia_state_mode ? {
        'directory' => "${mia_state_dir}/backgroundjobs",
        default     => "${mia_state_volume_base}-backgroundjobs",
      }
      $mia_state_volumes_api = ["${mia_state_name_api}:/var/lib/ferrogate"]
      $mia_state_volumes_backgroundjobs = ["${mia_state_name_backgroundjobs}:/var/lib/ferrogate"]
    } else {
      $mia_state_volumes_api = []
      $mia_state_volumes_backgroundjobs = []
    }

    if $mia_has_config and ($enable_api or $enable_backgroundjobs) {
      file { $conf_configdir_mia:
        ensure  => directory,
        require => File[$conf_configdir],
      }
      file { "${conf_configdir_mia}/mia.toml":
        ensure  => file,
        mode    => '0644',
        source  => $mia_config_source,
        content => $mia_config_content,
        require => File[$conf_configdir_mia],
      }
    }

    if $mia_embedded and ($enable_api or $enable_backgroundjobs) {
      if $mia_state_mode == 'directory' {
        if ! defined(File[$mia_state_dir]) {
          file { $mia_state_dir:
            ensure => directory,
            mode   => '0700',
          }
        }
        if $enable_api {
          file { $mia_state_name_api:
            ensure  => directory,
            mode    => '0700',
            require => File[$mia_state_dir],
          }
        }
        if $enable_backgroundjobs {
          file { $mia_state_name_backgroundjobs:
            ensure  => directory,
            mode    => '0700',
            require => File[$mia_state_dir],
          }
        }
      } else {
        if $enable_api {
          docker_volume { $mia_state_name_api:
            ensure => present,
          }
        }
        if $enable_backgroundjobs {
          docker_volume { $mia_state_name_backgroundjobs:
            ensure => present,
          }
        }
      }
    }

    $mia_state_require_api = $mia_embedded ? {
      true    => $mia_state_mode ? {
        'directory' => [File[$mia_state_name_api]],
        default     => [Docker_volume[$mia_state_name_api]],
      },
      default => [],
    }
    $mia_state_require_backgroundjobs = $mia_embedded ? {
      true    => $mia_state_mode ? {
        'directory' => [File[$mia_state_name_backgroundjobs]],
        default     => [Docker_volume[$mia_state_name_backgroundjobs]],
      },
      default => [],
    }
    $mia_config_require = $mia_has_config ? {
      true    => [File["${conf_configdir_mia}/mia.toml"]],
      default => [],
    }
  } else {
    $mia_state_require_api = []
    $mia_state_require_backgroundjobs = []
    $mia_config_require = []
    $mia_envs = []
    $mia_config_volumes = []
    $mia_socket_volumes = []
    $mia_state_volumes_api = []
    $mia_state_volumes_backgroundjobs = []
  }

  # Left undef (not []) when MIA is off, so the resource is untouched.
  $mia_requires_backgroundjobs_list = $mia_config_require + $mia_state_require_backgroundjobs
  $mia_requires_backgroundjobs = $mia_requires_backgroundjobs_list.empty ? {
    true    => undef,
    default => $mia_requires_backgroundjobs_list,
  }

  #API CONFIGS
  $base_envs_api = [
    "FACTER_ENABLE_SAML=${enable_saml}",
    "FACTER_DBSERVER=${db_server}",
    "FACTER_DBUSER=${db_user}",
    "FACTER_DBPORT=${db_port}",
    "FACTER_DBPASSWORD=${db_password.unwrap}",
    "FACTER_DBSCHEMA=${db_schema}",
    "FACTER_NETRISK_URL=${api_protocol}://${api_server}:${api_port}",
    "FACTER_SERVER_LOGGING=${logging}",
    "FACTER_EMAIL_FROM=${email_from}",
    "FACTER_EMAIL_SERVER=${email_server}",
    "FACTER_EMAIL_PORT=${email_port}",
    'FACTER_SERVER_CERTIFICATE_FILE=/netrisk/api.pfx',
    "FACTER_SERVER_CERTIFICATE_PWD=${api_ssl_cert_pwd.unwrap}",
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
    'FACTER_IDP_CERTIFICATE_FILE=/netrisk/idp.pem',
    'FACTER_SP_CERTIFICATE_FILE=/netrisk/sp.pfx',
    "FACTER_SP_CERTIFICATE_PWD=${sp_certificate_pwd.unwrap}",
  ]

  $envs_api = $base_envs_api + $master_key_env + $mia_envs

  file { "${conf_configdir_api}/certs":
    ensure  => directory,
    require => File[$conf_configdir_api],
  }
  -> file { "${conf_configdir_api}/certs/api.pfx":
    ensure  => file,
    source  => $api_ssl_cert_base64 ? { undef => $api_ssl_cert_file, default => undef },
    content => $api_ssl_cert_base64 ? { undef => undef, default => Binary($api_ssl_cert_base64, '%b') },
  }
  file { "${conf_configdir_api}/certs/idp.pem":
    ensure  => file,
    source  => $idp_certificate,
    require => File["${conf_configdir_api}/certs"],
  }
  file { "${conf_configdir_api}/certs/sp.pfx":
    ensure  => file,
    source  => $sp_certificate_base64 ? { undef => $sp_certificate_file, default => undef },
    content => $sp_certificate_base64 ? { undef => undef, default => Binary($sp_certificate_base64, '%b') },
    require => File["${conf_configdir_api}/certs"],
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
      "${conf_configdir_api}/certs/idp.pem:/netrisk/idp.pem",
      "${conf_configdir_api}/certs/sp.pfx:/netrisk/sp.pfx",
      "${conf_logsdir_api}:/var/log/netrisk",
      "${conf_homedir_api_plugins}:/netrisk/Plugins",
      "${conf_homedir_api_appdata}:/var/netrisk",
    ] + $mia_config_volumes + $mia_state_volumes_api + $mia_socket_volumes

    dockerapp::run { $api_service_name:
      image        => $image_name_api,
      ports        => $api_ports,
      volumes      => $volumes_api,
      environments => $envs_api,
      net          => $network_name,
      require      => [File["${conf_configdir_api}/certs/api.pfx"]] + $mia_config_require + $mia_state_require_api,
    }
  }

  #WEBSITE CONFIGS

  file { "${conf_configdir_website}/certs":
    ensure  => directory,
    require => File[$conf_configdir_website],
  }
  -> file { "${conf_configdir_website}/certs/website.pfx":
    ensure  => file,
    source  => $website_ssl_cert_base64 ? { undef => $website_ssl_cert_file, default => undef },
    content => $website_ssl_cert_base64 ? { undef => undef, default => Binary($website_ssl_cert_base64, '%b') },
  }

  $envs_website = [
    "FACTER_DBSERVER=${db_server}",
    "FACTER_DBUSER=${db_user}",
    "FACTER_DBPORT=${db_port}",
    "FACTER_DBPASSWORD=${db_password.unwrap}",
    "FACTER_DBSCHEMA=${db_schema}",
    "FACTER_NETRISK_URL=${api_protocol}://${api_server}:${api_port}",
    "FACTER_SERVER_LOGGING=${logging}",
    "FACTER_EMAIL_FROM=${email_from}",
    "FACTER_EMAIL_SERVER=${email_server}",
    "FACTER_EMAIL_PORT=${email_port}",
    'FACTER_SERVER_CERTIFICATE_FILE=/netrisk/website.pfx',
    "FACTER_SERVER_CERTIFICATE_PWD=${website_ssl_cert_pwd.unwrap}",
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

  $base_envs_console = [
    "FACTER_DBSERVER=${db_server}",
    "FACTER_DBUSER=${db_user}",
    "FACTER_DBPORT=${db_port}",
    "FACTER_DBPASSWORD=${db_password.unwrap}",
    "FACTER_DBSCHEMA=${db_schema}",
    "FACTER_SERVER_LOGGING=${logging}",
    "FACTER_NETRISK_USER=${user}",
    "FACTER_NETRISK_UID=${uid}",
  ]

  $envs_console = $base_envs_console + $master_key_env

  if $enable_console == true {
    $console_service_name = "${service_name}_console"

    $volumes_console = [
      "${conf_homedir_backups}:/backups",
      "${conf_logsdir_console}:/var/log/netrisk",
      "${conf_homedir_console_appdata}:/var/netrisk",
    ]

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
      volumes      => $volumes_console,
      net          => $network_name,
    }
  }

  $base_envs_backgroundjobs = [
    "FACTER_NETRISK_URL=${api_protocol}://${api_server}:${api_port}",
    "FACTER_DBSERVER=${db_server}",
    "FACTER_DBUSER=${db_user}",
    "FACTER_DBPORT=${db_port}",
    "FACTER_DBPASSWORD=${db_password.unwrap}",
    "FACTER_DBSCHEMA=${db_schema}",
    "FACTER_SERVER_LOGGING=${logging}",
    "FACTER_NETRISK_USER=${user}",
    "FACTER_NETRISK_UID=${uid}",
  ]

  $envs_backgroundjobs = $base_envs_backgroundjobs + $master_key_env + $mia_envs

  if $enable_backgroundjobs == true {
    $backgroundjobs_service_name = "${service_name}_backgroundjobs"

    $volumes_backgroundjobs = [
      "${conf_homedir_backups}:/backups",
      "${conf_logsdir_backgroundjobs}:/var/log/netrisk",
      "${conf_homedir_backgroundjobs_appdata}:/var/netrisk",
    ] + $mia_config_volumes + $mia_state_volumes_backgroundjobs + $mia_socket_volumes

    dockerapp::run { $backgroundjobs_service_name:
      image        => $image_name_backgroundjobs,
      environments => $envs_backgroundjobs,
      volumes      => $volumes_backgroundjobs,
      net          => $network_name,
      require      => $mia_requires_backgroundjobs,
    }
  }
}
