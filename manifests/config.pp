#
# cap config
#
define capistrano::config (
  $environment = $name,
) {

  concat { "/data/srv/config/deploy/${environment}.rb":
    ensure => present,
  }

  concat::fragment { "${environment}_multistage_server_header":
    target  => "/data/srv/config/deploy/${environment}.rb",
    content => template("${module_name}/config/deploy/multistage_header.rb.erb"),
    order   => '02',
  }

  #esearch/db choosing using NON VPC crons_${country_id} fact
  Concat::Fragment <<| tag == "${environment}_deploy_node" |>>

}
