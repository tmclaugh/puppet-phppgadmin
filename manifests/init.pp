# == Class: phppgadmin
#
# === Parameters
#
# [path] The path to install phppgadmin to (default: /srv/phpgadmin)
# [user] The user that should own that directory (default: www-data)
# [servers] An array of servers (default: [])
# [revision] The revision for the deployment (default: 'origin/REL_5-1')
# [use_package] Use OS package instead of Git. (default: false)
# [package_ensure] 'ensure' value passed to package resource if use_package is true. (default: installed)
#
# === Examples
#
#  class { 'phppgadmin':
#    path => "/srv/phppgadmin",
#    user => "www-data",
#    servers => [
#      {
#        desc => "local",
#        host => "127.0.0.1",
#      },
#      {
#        desc => "other",
#        host => "192.168.1.30",
#      }
#    ]
#  }
#
# === Authors
#
# Arthur Leonard Andersen <leoc.git@gmail.com>
#
# === Copyright
#
# See LICENSE file, Arthur Leonard Andersen (c) 2013

# Class:: phppgadmin
#
#
class phppgadmin (
  $path = '/srv/phppgadmin',
  $user = 'www-data',
  $servers = [],
  $revision = 'origin/REL_5-1',
  $use_package = false,
  $package_ensure = installed
) {

  if $use_package == true {
    package { 'phpPgAdmin':
      ensure => $package_ensure
    }

    $phppgadmin_conf_require = Package['phpPgAdmin']
    $phppgadmin_conf_path    = '/etc/phpPgAdmin/config.inc.php'
  } else {
    file { $path:
      ensure         => directory,
      owner          => $user,
    }
    ->
    vcsrepo { $path:
      ensure   => present,
      provider => git,
      source   => 'git://github.com/phppgadmin/phppgadmin.git',
      user     => $user,
      revision => $revision,
    }

    $phppgadmin_conf_require = Vcsrepo[$path]
    $phppgadmin_conf_path    = "${path}/conf/config.inc.php"
  }

  file { 'phppgadmin-conf':
    path    => $phppgadmin_conf_path,
    content => template('phppgadmin/config.inc.php.erb'),
    owner   => $user,
    require => $phppgadmin_conf_require
  }

} # Class:: phppgadmin
