#
# This is to be called on all deployment nodes
#
# [primary_node]
# where db migrations are run from, you should only have one.
#
#  capistrano::node { 'foo_repo':
#    environments   => [ 'production', 'staging' ],
#    app_path       => '/opt/puppet',
#    ssh_key_source => 'puppet:///modules/applicatoin',
#  }
#
define capistrano::node (
  $environments,
  $primary_node       = false,                   #am I the node that you run primary tasks from? you only need one (db migrations)
  $app_name           = $name,                    #the name of the application
  $deploy_user        = 'cap',
  $deploy_path        = "/deploy/${name}",   #the path that you go to, to run the deploy scripts
  $app_user           = 'www-data',
  $app_path           = "/var/www/${name}",
  $cap_ssh_privatekey = false,
  $ssh_key_source     = undef,
) {

  $app_name_and_environment  = prefix($environments, "${app_name}_")

  capistrano::environments::node { $app_name_and_environment:
    primary_node => $primary_node,
    deploy_path  => $deploy_path,
  }

  $home_path = dirname($deploy_path)

  ensure_resource('file', $app_path, {
    ensure   => directory,
    owner    => $app_user,
    group    => $deploy_user,
    mode     => 770,
  })

  #the stuff that needs to be the same for all definitions should maybe go into init or install and only require?
  ensure_resource('group', $deploy_user, {
    gid     => fqdn_rand(50000, $::deploy_user) + 5000,    #ensure always over 1000
  })
  ensure_resource('user', $deploy_user, {
    shell   => '/bin/bash',
    uid     => fqdn_rand(50000, $::deploy_user) + 5000,    #ensure always over 1000
    gid     => fqdn_rand(50000, $::deploy_user) + 5000,    #ensure always over 1000
    home    => $home_path,
    require => Group[$deploy_user],
  })

  #directory setup
  ensure_resource('exec', "setup_deploy_path_${app_name}", {
    command => "mkdir -p ${deploy_path}/config/deploy && chown -R ${deploy_user}:${deploy_user} ${deploy_path}",
    creates => $deploy_path,
    path    => '/bin',
  })
  ensure_resource('exec', "setup_app_path_${app_name}", {
    command => "mkdir -p ${app_path}/config/app && chown -R ${app_user}:${app_user} ${app_path}",
    creates => $app_path,
    path    => '/bin',
  })

  #ssh key for sshing between nodes for capistrano
  ensure_resource('file', "${home_path}/.ssh", {
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_user,
  })
  ensure_resource('concat', "${home_path}/.ssh/config", {
    ensure => present,
    mode   => '644',
  })
  if ($cap_ssh_privatekey == true) {
    $priv_key_ensure = file
  } else {
    $priv_key_ensure = absent
  }
  ensure_resource('file', "${home_path}/.ssh/id_rsa", {
    ensure => $priv_key_ensure,
    source => "${ssh_key_source}/id_rsa",
    owner  => $deploy_user,
    group  => $deploy_user,
    mode   => '400',
  })
  ensure_resource('file', "${home_path}/.ssh/authorized_keys", {
    ensure => file,
    source => "${ssh_key_source}/id_rsa.pub",
    owner  => $deploy_user,
    group  => $deploy_user,
    mode   => '400',
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
}
