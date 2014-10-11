#
# cap puppet module
# you need to use capistrano::node { 'production': }
# production and staging are assumed
#
class capistrano {

  class { 'install': }
  config { [ 'production', 'staging' ]: }

}
