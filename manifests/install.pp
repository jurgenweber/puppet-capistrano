class capistrano::install {

  #setup capifony and capistrano deploy env
  package { 'capistrano':
    ensure   => '3.2.1',
    provider => gem,
  }
  package { 'capistrano-file-permissions':
    ensure   => '0.1.0',
    provider => gem,
  }

}
