#
# This is to be called on all deployment nodes
#
# [primary_node]
# where db migrations are run from, you should only have one.
#
# capistrano::node { 'production', 'staging': }
#
define capistrano::node (
  $environment  = $name,
  $primary_node = false,
) {
  @@concat::fragment { "${environment}_multistage_servers":
    target  => "/data/srv/config/deploy/${environment}.rb",
    content => template("${module_name}/config/deploy/multistage_servers.rb.erb"),
    order   => '05',
    tag     => "${environment}_deploy_node",
  }
}
