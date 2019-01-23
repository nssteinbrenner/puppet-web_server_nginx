class web_server::service {
  service { 'iptables':
    ensure => running,
    enable => true,
  }
}
