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



}
