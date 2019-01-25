# puppet-web_server_nginx

Configures a (very) basic nginx web server with SELinux enabled that displays "Hello World!".

Some things have been removed before uploading, such as my e-mail address.

### Usage

You are required to replace the e-mail address (in the letsencrypt class block), the $dns_token variable, and the $webserver_url variable in manifests/config.pp in order for it to work. Otherwise, the dynamic DNS script and the LetsEncrypt certificate generation will error out, causing the puppet run to stop. $dns_token and $webserver_url must be acquired from duckdns.org

#### How to acquire $webserver_url from duckdns.org
1. Login with your preferred method of authentication (e.g GitHub)
 2. There will be a box on the page that looks like "http://sub domain     .duckdns.org", replace subdomain with your desired name.
 3. Your $webserver_url will be nameyouentered.duckdns.org
 
 #### How to acquire $dns_token from duckdns.org
 1. After acquiring a $webserver_url and logging in, click "install" at the top.
 2. Select "linux cron" if it is not already selected.
 3. Underneath "first step - choose a domain.", click on the drop down box and select the domain from earlier.
 4. There will be blocks with commands inside, look for the block that starts with 'echo url="https://www.duckdns.org"'
 5. In that block, look for "&token". The $dns token will be the character between "&token" and "&ip="
 
 #### Replacing $dns_token, $webserver_url, and the email in config.pp
1. Open config.pp in your editor of choice and replace 'sparkswebserver.duckdns.org' with 'yourdomain.duckdns.org' (depending on what domain you have).
2. Then, replace $dns_token = 'redacted' with $dns_token = 'yourdnstoken'
3. Afterwards, go down to the block that says 'class { ::letsencrypt:', find 'email =>' and replace 'redacted' with 'youremail@domain.com'

#### Install
The module is called web_server, so put the directories in this repository in a modules directory inside of your puppet module path called web_server. For example, /etc/puppetlabs/code/environments/production/modules/web_server. You can find your module path by typing 'puppet config print modulepath'. Then, in your environment manifests directory (e.g /etc/puppetlabs/code/enviroments/production/manifests), edit site.pp and include the following:

    resources { 'firewall':
        purge => true,
    }
    node 'yourpuppetnode.puppet.com' {
        include web_server
    }
Replace 'yourpuppetnode.puppet.com' with the node you'd like to run this on.

NOTE: If you do not change $webserver_url, $dns_token and the letsencrypt e-mail, the puppet run will error out due to a failure in configuring dynamic dns and letsencrypt.

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
1/25/2019 - Testing was done on a server that had been modified prior and was not a minimal install, and when this was tested on a minimal install it was non-functional. The following changes were made to add functionality for a minimal Centos 7.5 install, additionally there are some general bug fixes:

    - (Quality of Life) Install mlocate, vim, and psmisc.
    - Create /var/www
    - Edited cron syntax for duckdns, was not adding it to the crontab prior.
    - Enabled SELinux boolean httpd_setrlimit.
    - Execute duckdns script immediately after install.
    - LetEncrypt plugin changed to 'standalone'.
    - Execute LetsEncrypt renew script immediately after install.
    - Removed testing/old unused code.


1/24/2019 - Nginx plugin was breaking the web server when the crontab would run. I thought the nginx plugin used the nginx systemd service, but rather it is a separe module installed exclusively for certbot that I did not install. Changing to default letsencrypt resolved the issue.
