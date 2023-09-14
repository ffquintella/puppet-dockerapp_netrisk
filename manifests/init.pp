# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include dockerapp_netrisk
class dockerapp_netrisk(
  $service_name = 'netrisk',
  $version = 'latest',
  $api_port = '5443',
  $site_port = '443',
  $db_server = '',
  $db_port = '3306',
  $db_schema = 'netrisk',
  $db_user = 'netrisk',
  $db_password = '',
  $ssl_cert_file = '',
  $ssl_cert_pwd = ''
) {

include dockerapp::basedirs
include dockerapp::params

class {"dockerapp":
  manage_docker => false
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

}
