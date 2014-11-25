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
  $app_name           = $name,                       #the name of the application
  $environments       = [ 'production', 'staging' ],
  $deploy_user        = 'cap',
  $deploy_path        = "/deploy/${name}",       #the path that you go to, to run the deploy scripts
  $app_user           = 'www-data',                  #for example your webserver user
  $app_path           = "/var/www/${name}",
  $scm                = 'git',
  $repo_address,                                     #github.com:/foo/
  $cap_gems           = [],
  $keep_releases      = '3',
  $linked_files       = [],
  $linked_dirs        = [],
  $copy_exclude       = [ '.git/*', '.svn/*', '.DS_Store', '.gitignore' ],
  $ssh_key_source     = undef,
  $git_keys           = false,                       #are you supplying git keys?
  $deploy_rb_tmp_src  = "${module_name}/config/deploy.rb.erb",
) {

  #install me
  capistrano::install { $app_name:
    scm            => $scm,
  }

  #setup the two environemnts
  capistrano::config { $app_name:
    environments       => $environments,
    deploy_path        => $deploy_path,
    app_path           => $app_path,
    deploy_user        => $deploy_user,
    app_user           => $app_user,
    scm                => $scm,
    repo_address       => $repo_address,
    cap_gems           => $cap_gems,
    keep_releases      => $keep_releases,
    linked_files       => $linked_files, 
    linked_dirs        => $linked_dirs, 
    copy_exclude       => $copy_exclude, 
    ssh_key_source     => $ssh_key_source,
    git_keys           => $git_keys,
  }

  #I assume the deploy host will not serve code but we will stil deploy here to
  #do 'stuff' that only one server can do.... like db migrations
  capistrano::node { $app_name: 
    environments       => $environments,
    deploy_user        => $deploy_user,
    deploy_path        => $deploy_path,
    app_user           => $app_user,
    app_path           => $app_path,
    primary_node       => true,
    cap_ssh_privatekey => true,
    ssh_key_source     => $ssh_key_source,
  }

}
