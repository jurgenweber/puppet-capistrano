#
#
#
define capistrano::environments::node (
  $deploy_path,
  $primary_node = false,
  $external_cleanup,
  $app_path,
) {

  $split_app_name_and_environment = split($name, '_')

  $app_name    = $split_app_name_and_environment[0]
  $environment = $split_app_name_and_environment[1]

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

  @@concat::fragment { "${environment}_multistage_servers_${app_name}_${hostname}":
    target  => "${deploy_path}/config/deploy/${environment}.rb",
    content => template("${module_name}/config/deploy/multistage_servers.rb.erb"),
    order   => '05',
    tag     => "${environment}_deploy_node_${app_name_tag}",
  }

  if ($external_cleanup == true) {
    $cron_hour_production         = fqdn_rand(23, "${id} ${app_name} ${environment}")
    $cron_hour_staging_morning    = fqdn_rand(11, "${id} ${app_name} ${environment}")
    $cron_hour_staging_afternoon  = $cron_hour_staging_morning + 12

    $cron_minute = fqdn_rand(45, "${id} ${app_name} ${environment} ${module_name}") + 10

    cron { "clean_up_release_directory_${id}${app_name}_${environment}":
      ensure     => present,
      command    => "/usr/local/bin/clean_up_deploy_dir.sh -d ${app_path}/${environment}/releases -r 5",
      hour       => $environment ? { 'staging' => [ $cron_hour_staging_morning, $cron_hour_staging_afternoon ], default => $cron_hour_production },
      minute     => $cron_minute,
      user       => 'root',
      weekday    => '1-5', #the logic being we do not deploy on weekends and it's our biggest traffic time and we don't want htis happening on the weekend
    }
  }
}
