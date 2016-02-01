#
# cap config
#
define capistrano::config (
  $app_name           = $name,
  $environments,
  $deploy_path,
  $app_path,
  $deploy_user,
  $app_user,
  $scm,
  $repo_address,
  $cap_gems           = [],
  $cap_import         = [],
  $keep_releases      = '3',
  $linked_files       = [],
  $linked_dirs        = [],
  $copy_exclude       = [ '.git/*', '.svn/*', '.DS_Store', '.gitignore' ],
  $ssh_key_source     = undef,    #you need to create files to server to use this for github
  $git_keys           = false,    #are you supplying git repo keys at the same ssh key source?
  $deploy_rb_tmp_src  = "${module_name}/config/deploy.rb.erb",
) {

  #deal wiht git repo's with company/repo.name.
  $app_name_slash_check = split($app_name, '/')
  if ($app_name_slash_check[1] == '') {
    $app_name_tag  = $app_name_slash_check
  } else {
    $app_name_tag  = join(concat([ $app_name_slash_check[0] ], [ "${app_name_slash_check[1]}" ]), '_')
  }

  #Capfile
  file {
    "${deploy_path}/Capfile":
      ensure  => file,
      owner   => $deploy_user,
      group   => $deploy_user,
      content => template("${module_name}/Capfile.erb"),
      require => Exec["setup_deploy_path_${app_name}"];
    "${deploy_path}/config/deploy.rb":
      ensure  => file,
      owner   => $deploy_user,
      group   => $deploy_user,
      content => template($deploy_rb_tmp_src);
    "${deploy_path}/lib":
      ensure  => directory,
      owner   => $deploy_user,
      group   => $deploy_user;
    "${deploy_path}/lib/capistrano":
      ensure  => directory,
      owner   => $deploy_user,
      group   => $deploy_user;
    "${deploy_path}/lib/capistrano/tasks":
      ensure  => directory,
      owner   => $deploy_user,
      group   => $deploy_user;
  }

  $home_path = dirname($deploy_path)

  $app_name_and_environment  = prefix($environments, "${app_name}_")

  capistrano::environments::config { $app_name_and_environment:
    deploy_path => $deploy_path,
    deploy_user => $deploy_user,
  }
}
