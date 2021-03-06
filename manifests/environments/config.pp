#
#
#
define capistrano::environments::config (
  $deploy_path,
  $deploy_user,
) {

  $split_app_name_and_environment = split($name, '_')

  $app_name    = $split_app_name_and_environment[0]
  $environment = $split_app_name_and_environment[1]

  #server declartions
  concat { "${deploy_path}/config/deploy/${environment}.rb":
    ensure => present,
    owner  => $deploy_user,
    group  => $deploy_user,
  }

  concat::fragment { "${environment}_multistage_server_header_${app_name}":
    target  => "${deploy_path}/config/deploy/${environment}.rb",
    content => template("${module_name}/config/deploy/multistage_header.rb.erb"),
    order   => '02',
  }

  $app_name_slash_check = split($app_name, '/')
  if ($app_name_slash_check[1] == '') {
    $app_name_tag  = $app_name_slash_check
  } else {
    $app_name_tag  = join(concat([ $app_name_slash_check[0] ], [ "${app_name_slash_check[1]}" ]), '_')
  }

  #esearch/db choosing using NON VPC crons_${country_id} fact
  Concat::Fragment <<| tag == "${environment}_deploy_node_${app_name_tag}" |>>

}
