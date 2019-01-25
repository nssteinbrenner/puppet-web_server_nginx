class web_server::service {
  service { 'iptables':
    ensure => running,
    enable => true,
  }
  #class { 'nginx':
    #manage_repo    => true,
    # package_source => 'nginx-mainline',
    #  }

}
