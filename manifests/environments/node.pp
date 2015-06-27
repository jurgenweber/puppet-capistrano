#
#
#
define capistrano::environments::node (
  $deploy_path,
  $primary_node = false,
  $app_path,
  $deploy_user,
) {

  $split_app_name_and_env = split($name, '_')

  $app_name = $split_app_name_and_env[0]
  $env      = $split_app_name_and_env[1]

  #directory setup
  ensure_resource('exec', "setup_app_path_${env}_${app_name}", {
    command => "mkdir -p ${app_path}/${env}/shared/app/config && chown -R ${deploy_user}:${deploy_user} ${app_path}/${env}/shared/app/config",
    creates => "${app_path}/${env}/shared/app/config",
    path    => '/bin',
  })

  #deal wiht git repo's with company/repo.name.
  $app_name_slash_check = split($app_name, '/')
  if ($app_name_slash_check[1] == '') {
    $app_name_tag  = $app_name_slash_check
  } else {
    $app_name_tag  = join(concat([ $app_name_slash_check[0] ], [ "${app_name_slash_check[1]}" ]), '_')
  }

  if ($primary_node == true) {
    $server_role = 'primary_node'
  } else {
    $server_role = 'node'
  }

  @@concat::fragment { "${env}_multistage_servers_${app_name}_${hostname}":
    target  => "${deploy_path}/config/deploy/${env}.rb",
    content => template("${module_name}/config/deploy/multistage_servers.rb.erb"),
    order   => '05',
    tag     => "${env}_deploy_node_${app_name_tag}",
  }
}
