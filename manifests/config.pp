#
# cap config
#
define capistrano::config (
  $app_name      = $name,
  $environments,
  $deploy_path,
  $app_path,
  $deploy_user,
  $app_user,
  $scm,
  $repo_address,
  $cap_gems      = [],
  $keep_releases = '3',
  $linked_files  = [],
  $linked_dirs   = [],
  $copy_exclude  = [ '.git/*', '.svn/*', '.DS_Store', '.gitignore' ]
) {

  #the stuff that needs to be the same for all definitions should maybe go into init or install and only require?
  ensure_resource('group', $deploy_user, {
    gid     => fqdn_rand(50000, $::fqdn) + 5000,    #ensure always over 1000
  })
  ensure_resource('user', $deploy_user, {
    shell   => '/bin/bash',
    uid     => fqdn_rand(50000, $::fqdn) + 5000,    #ensure always over 1000
    gid     => fqdn_rand(50000, $::fqdn) + 5000,    #ensure always over 1000
    require => Group[$deploy_user],
  })

  #directory setup
  ensure_resource('exec', "setup_deploy_path_${app_name}", {
    command => "mkdir -p ${deploy_path}/deploy && chown -R ${deploy_user}:${deploy_user} ${deploy_path}",
    creates => $deploy_path,
    path    => '/bin',
  })

  #Capfile
  ensure_resource('file', "${deploy_path}/Capfile", {
    ensure  => file,
    owner   => $deploy_user,
    group   => $deploy_user,
    content => template("${module_name}/Capfile.erb"),
    require => Exec["setup_deploy_path_${app_name}"],
  }) 

  #capistarno deploy.rb
  ensure_resource('file', "${deploy_path}/deploy/deploy.rb", {
    ensure  => file,
    owner   => $deploy_user,
    group   => $deploy_user,
    content => template("${module_name}/config/deploy.rb.erb"),
  })

  $app_name_and_environment  = prefix($environments, "${app_name}_")

  capistrano::environments::config { $app_name_and_environment: 
    deploy_path => $deploy_path,
  }
}
