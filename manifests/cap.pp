#
# cap puppet module
# you need to use capistrano::node { 'production': }
# production and staging are assumed
#
#
#capistrano::cap { 'puppet':
#  repo_address  => 'git@example.com:git_repo.git',
#}
#
define capistrano::cap (
  $app_name        = $name,                       #the name of the application
  $environments    = [ 'production', 'staging' ],
  $deploy_path     = "/deploy/${name}",       #the path that you go to, to run the deploy scripts
  $app_path        = "/var/www/${name}",
  $deploy_user     = 'cap',
  $app_user        = 'www-data',                  #for example your webserver user
  $scm             = 'git',
  $repo_address,                                  #git@github.com/foo/bar.git
) {

  #install me
  capistrano::install { $app_name:
    scm            => $scm,
  }

  #setup the two environemnts
  capistrano::config { $app_name:
    environments   => $environments,
    deploy_path    => $deploy_path,
    app_path       => $app_path,
    deploy_user    => $deploy_user,
    app_user       => $app_user,
    scm            => $scm,
    repo_address   => $repo_address,
  }

  #I assume the deploy host will not serve code but we will stil deploy here to
  #do 'stuff' that only one server can do.... like db migrations
  capistrano::node { $app_name: 
    environments   => $environments,
    primary_node   => true,
  }

}
