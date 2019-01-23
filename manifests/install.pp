class web_server::install {

  case $facts['os']['family'] {
    'RedHat', 'CentOS': { $package_manager = 'yum' }
    'Debian', 'Ubuntu': { $package_manager = 'apt-get' }
    default:            { warning('This operating system is not supported.') }
  }

  package { 'firewalld':
    ensure   => absent,
    provider => $package_manager,
  }

  package { 'iptables-services':
    ensure   => present,
    provider => $package_manager,
  }

  package { 'setroubleshoot-server':
    ensure   => present,
    provider => $package_manager,
  }

  class { 'nginx':
    manage_repo    => true,
    package_source => 'nginx-mainline',
  }

  include web_server::config

}
