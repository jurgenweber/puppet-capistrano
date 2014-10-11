#
# cap config
#
define capistrano::config (
  $environment,
  $app_name,
  $deploy_path,
  $app_path,
  $deploy_user,
  $webserver_user,
  $scm,
  $repo_address,
  $keep_releases = '3',
  $linked_files  = [],
  $linked_dirs   = [],
  $copy_exclude  = [ '.git/*', '.svn/*', '.DS_Store', '.gitignore' ]
) {

  if ! defined(Group[$deploy_user]) {
    group { $deploy_user:
      gid     => fqdn_rand(50000, $app_name) + 5000    #ensure always over 1000
    }->
    user { $deploy_user:
      uid     => fqdn_rand(50000, $app_name) + 5000    #ensure always over 1000
      gid     => fqdn_rand(50000, $app_name) + 5000    #ensure always over 1000
    }
  }

  #Capfile
  if ! defined(File["${deploy_path}/Capfile"]) {
    file { "${deploy_path}/Capfile":
      ensure  => file,
      owner   => $deploy_user,
      group   => $deploy_user,
      content => tempalte("${module_name}/Capfile.erb"),
    }  
  }

  #capistarno deploy.rb
  if ! defined(File["${deploy_path}/deploy/deploy.rb"]) {
    file { "${deploy_path}/deploy/deploy.rb":
      ensure  => file,
      owner   => $deploy_user,
      group   => $deploy_user,
      content => tempalte("${module_name}/config/deploy.rb.erb"),
    }
  }

  #server declartions
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