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
  $keep_releases      = '3',
  $linked_files       = [],
  $linked_dirs        = [],
  $copy_exclude       = [ '.git/*', '.svn/*', '.DS_Store', '.gitignore' ],
  $ssh_key_source     = undef,    #you need to create files to server to use this for github
  $git_keys           = false,    #are you supplying git repo keys at the same ssh key source?
) {

  #Capfile
  ensure_resource('file', "${deploy_path}/Capfile", {
    ensure  => file,
    owner   => $deploy_user,
    group   => $deploy_user,
    content => template("${module_name}/Capfile.erb"),
    require => Exec["setup_deploy_path_${app_name}"],
  }) 

  #deal wiht git repo's with company/repo.name.
  $app_name_slash_check = split($app_name, '/')
  if ($app_name_slash_check[1] == '') {
    $app_name_tag  = $app_name_slash_check
  } else {
    $app_name_tag  = concat([ $app_name_slash_check[0] ], [ "_${app_name_slash_check[1]}" ])
  }

  #capistarno deploy.rb
  ensure_resource('file', "${deploy_path}/config/deploy.rb", {
    ensure  => file,
    owner   => $deploy_user,
    group   => $deploy_user,
    content => template("${module_name}/config/deploy.rb.erb"),
  })

  $home_path = dirname($deploy_path)

  ensure_resource('concat', "${home_path}/.ssh/config", {
    ensure => present,
    mode   => '644',
  })

  #github/git needs ssh keys
  if ($ssh_key_source != undef) and ($git_keys == true) {
    file { "${deploy_path}/id_rsa":
      ensure => file,
      source => "${ssh_key_source}/${app_name}_id_rsa",
      owner  => $deploy_user,
      group  => $deploy_user,
      mode   => '400',
    }->
    file { "${deploy_path}/id_rsa.pub":
      ensure => file,
      source => "${ssh_key_source}/${app_name}_id_rsa.pub",
      owner  => $deploy_user,
      group  => $deploy_user,
      mode   => '400',
    }
    concat::fragment { "${app_name}_hostname":
      target  => "${home_path}/.ssh/config",
      content => template("${module_name}/ssh_config.erb"),
      order   => '0',
    }
  }

  $app_name_and_environment  = prefix($environments, "${app_name}_")

  capistrano::environments::config { $app_name_and_environment: 
    deploy_path => $deploy_path,
    deploy_user => $deploy_user,
  }
}
