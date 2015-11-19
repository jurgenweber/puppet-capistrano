#
#
#
define capistrano::environments::node (
  $deploy_path,
  $primary_node = false,
  $app_user,
  $app_path,
  $deploy_user,
  $external_cleanup,
) {

  $split_app_name_and_env = split($name, '_')

  $app_name = $split_app_name_and_env[0]
  $env      = $split_app_name_and_env[1]

  #directory setup
  ensure_resource('exec', "setup_app_path_${env}_${app_name}", {
    command => "mkdir -p ${app_path}/${env}/shared/app/config && chown -R ${deploy_user}:${deploy_user} ${app_path}/${env}/shared",
    creates => "${app_path}/${env}/shared/app/config",
    path    => '/bin',
    require => User[$deploy_user],
  })
  ensure_resource('file', "${app_path}/${env}", {
    ensure  => directory,
    owner   => $app_user,
    group   => $deploy_user,
    mode    => '0770',
    require => [ User[$deploy_user], Exec["setup_app_path_${env}_${app_name}"] ],
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

  if ($external_cleanup == true) {
    $cron_hour_production         = fqdn_rand(23, "${id} ${app_name} ${env}")
    $cron_hour_staging_morning    = fqdn_rand(11, "${id} ${app_name} ${env}")
    $cron_hour_staging_afternoon  = $cron_hour_staging_morning + 12

    $cron_minute = fqdn_rand(45, "${id} ${app_name} ${env} ${module_name}") + 10

    cron { "clean_up_release_directory_${id}${app_name}_${env}":
      ensure     => present,
      command    => "/usr/local/bin/clean_up_deploy_dir.sh -d ${app_path}/${env}/releases -r 5",
      hour       => $env ? { 'staging' => [ $cron_hour_staging_morning, $cron_hour_staging_afternoon ], default => $cron_hour_production },
      minute     => $cron_minute,
      user       => 'root',
      weekday    => '1-5', #the logic being we do not deploy on weekends and it's our biggest traffic time and we don't want htis happening on the weekend
    }
  }
}
