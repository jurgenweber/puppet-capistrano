#
# setup capifony and capistrano deploy env
#
define capistrano::install ( 
  $scm = 'git',
) {

  case $scm {
    'git': {
      ensure_resource('class', 'git', {})
    }
  }

  ensure_resource('class', 'ruby', {})

  ensure_resource('package', 'capistrano', {
    ensure   => '3.2.1',
    provider => gem,
    require  => Class['ruby'],
  })

  ensure_resource('package', 'capistrano-file-permissions', {
    ensure   => '0.1.0',
    provider => gem,
    require  => Package['capistrano'],
  })

}
