class web_server::config {
  $ssh_port       = '22'
  $webserver_user = 'www-data'
  $webserver_root = '/var/www/web_server'
  $webserver_url  = 'sparkswebserver.duckdns.org'
  $cert_dir       = '/var/lib/puppet/ssl/certs'
  $key_dir        = '/var/lib/puppet/ssl/private_keys'
  $dns_token      = 'redacted'

  class { ::letsencrypt:
    email          => 'redacted',
    configure_epel => false,
  }

  class { selinux:
    mode => 'enforcing',
    type => 'targeted',
  }

  user { $webserver_user:
    ensure => present,
    shell  => '/sbin/nologin',
  }

  file { '/duckdns':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  file { '/duckdns/duck.log':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
  }

  $duckdns_hash = {
    'webserver_url' => $webserver_url,
    'dns_token'     => $dns_token,
  }

  file { '/duckdns/duck.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => epp('web_server/duck.sh.epp', $duckdns_hash),
  }

  file { $webserver_root:
    ensure => directory,
    owner  => $webserver_user,
    group  => $webserver_user,
    mode   => '0444',
  }

  file { "${webserver_root}/index.html":
    ensure => file,
    owner  => $webserver_user,
    group  => $webserver_user,
    mode   => '0444',
    source => 'puppet:///modules/web_server/index.html',
  }

  selinux::fcontext { $webserver_root:
    ensure   => present,
    seltype  => 'httpd_sys_content_t',
    pathspec => "${webserver_root}(/.*)?",
  }

  cron::job { 'duckdns':
    ensure      => present,
    minute      => '*/5',
    user        => 'root',
    description => "Refresh dynamic DNS for ${webserver_url}",
  }

  Firewall {
    require => undef,
  }

  firewall { '000 accept ssh port':
    proto  => 'tcp',
    dport  => $ssh_port,
    action => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 reject local traffic not on lo interface':
    proto       => 'all',
    iniface     => '! lo',
    destination => '127.0.0.1/8',
    action      => 'reject',
  }->
  firewall { '003 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }->
  firewall { '004 accept http/https port 80/443 traffic':
    proto  => 'tcp',
    dport  => ['80','443'],
    action => 'accept',
  }->
  firewall { '999 drop all':
    proto  => 'all',
    action => 'reject',
    before => undef,
  }

  letsencrypt::certonly { $webserver_url:
    domains              => [$webserver_url],
    plugin               => 'nginx',
    manage_cron          => true,
    cron_hour            => [0,12],
    cron_minute          => '30',
    cron_before_command  => '/bin/systemctl stop nginx',
    cron_success_command => '/bin/systemctl start nginx',
    suppress_cron_output => true,
    before               => Service['nginx'],
  }

  nginx::resource::server { $webserver_url:
    ensure               => present,
    www_root             => $webserver_root,
    use_default_location => false,
    listen_port          => 80,
    ssl                  => true,
    ssl_port             => 443,
    ssl_cert             => "/etc/letsencrypt/live/${webserver_url}/fullchain.pem",
    ssl_key              => "/etc/letsencrypt/live/${webserver_url}/privkey.pem",
    access_log           => '/var/log/nginx/puppet_access.log',
    error_log            => '/var/log/nginx/puppet_error.log',
    index_files          => ['index.html'],
  }
}
