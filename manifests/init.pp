#
# cap puppet module
# you need to use capistrano::node { 'production': }
# production and staging are assumed
#
#
#class { 'capistrano': 
#  app_name      => 'puppet',
#  repo_address  => 'git@warvm-mail01.space-marine.org:puppet.git',
#}
#
class capistrano (
  $app_name        = 'my_app',    #the name of the application
  $deploy_path     = "/deploy/${app_name}",   #the path that you go to, to run the deploy scripts
  $app_path        = "/var/www/${app_name}",
  $deploy_user     = 'cap',
  $app_user        = 'www-data',    #for example your webserver user
  $scm             = 'git',
  $repo_address,                  #git@github.com/foo/bar.git
) {

  #install me
  class { 'install': }

  #setup the two environemnts
  config { [ 'production', 'staging' ]: 
    app_name       => $app_name,
    deploy_path    => $deploy_path,
    app_path       => $app_path,
    deploy_user    => $deploy_user,
    app_user       => $app_user,
    scm            => $scm,
    repo_address   => $repo_address,
  }

  #I assume the deploy host will not server code but we will stil ldeploy here to
  #do 'stuff' that only one server can do.... like db migrations
  node { [ 'production', 'staging' ]: 
    primary_node => true,
  }

}
