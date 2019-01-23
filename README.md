# puppet-web_server_nginx

Configures a (very) basic nginx web server with SELinux enabled that displays "Hello World!".

Some things have been removed before uploading, such as my e-mail address.

### What it configures
DuckDNS for dynamic DNS configuration.
LetsEncrypt certificate for SSL
Nginx from mainline branch
iptables firewall with ssh, http, https open and to accept established/related connections.
SeLinux context for www root directory.

### To Do 
The case at the top of install.pp is misleading, while it changes the package manager, I did not prepare this with Debian/Ubuntu in mind at all, and it does not work with apt-get distros. Need to look more into Debian/Ubuntu to see the differences between them and a yum/rpm based distro in terms of package names and configuration.

### Required modules
puppet-selinux 1.6.1
puppetlabs-firewall 1.15
puppet-nginx 0.15.0
puppet-cron 1.3.1
puppet-letsencrypt 3.0.0
stahnma-epel 1.3.1
