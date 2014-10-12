#
#
#
define capistrano::environments::node (
  $deploy_path,
  $primary_node = false,
) {

  $split_app_name_and_environment = split($name, '_')

  $app_name    = $split_app_name_and_environment[0]
  $environment = $split_app_name_and_environment[1]

  @@concat::fragment { "${environment}_multistage_servers_${app_name}":
    target  => "${deploy_path}/config/deploy/${environment}.rb",
    content => template("${module_name}/config/deploy/multistage_servers.rb.erb"),
    order   => '05',
    tag     => "${environment}_deploy_node_${app_name}",
  }
}
