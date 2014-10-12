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
  $environments,
  $primary_node = false,                   #am I the node that you run primary tasks from? you only need one (db migrations)
  $app_name     = $name,                    #the name of the application
  $deploy_path  = "/deploy/${name}",   #the path that you go to, to run the deploy scripts
) {

  $app_name_and_environment  = prefix($environments, "${app_name}_")

  capistrano::environments::node { $app_name_and_environment:
    primary_node => $primary_node,
    deploy_path  => $deploy_path,
  }

}
