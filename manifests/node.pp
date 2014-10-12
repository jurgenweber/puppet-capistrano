#
# This is to be called on all deployment nodes
#
# [primary_node]
# where db migrations are run from, you should only have one.
#
# capistrano::node { 'production', 'staging': }
#   app_name => 'my_app',                  #needs to be the same as previously stated
# }
#
define capistrano::node (
  $environment  = $name,
  $primary_node = false,                   #am I the node that you run primary tasks from? you only need one (db migrations)
  $app_name,                               #the name of the application
  $deploy_path  = "/deploy/${app_name}",   #the path that you go to, to run the deploy scripts
) {
  @@concat::fragment { "${environment}_multistage_servers_${app_name}":
    target  => "${deploy_path}/deploy/${environment}.rb",
    content => template("${module_name}/config/deploy/multistage_servers.rb.erb"),
    order   => '05',
    tag     => "${environment}_deploy_node_${app_name}",
  }
}
