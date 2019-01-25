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

### Changelog
1/25/2019 - Testing was done on a server that had been modified prior and was not a minimal install, and when this was tested on a minimal install it was non-functional. The following changes were made to add functionaly for a minimal Centos 7.5 install, additionally there are some general bug fixes:

    - (Quality of Life) Install mlocate, vim, and psmisc.
    - Create /var/www (previous server had apache installed, which automatically created that directory.
    - Edited cron syntax for duckdns, was not adding it to the crontab prior.
    - Enabled SELinux boolean httpd_setrlimit.
    - Execute duckdns script immediately after install.
    - LetEncrypt plugin changed to 'standalone'.
    - Execute LetsEncrypt renew script immediately after install.
    - Removed testing/old unused code.


1/24/2019 - Nginx plugin was breaking the web server when the crontab would run. I thought the nginx plugin used the nginx systemd service, but rather it is a separe module installed exclusively for certbot that I did not install. Changing to default letsencrypt resolved the issue.
