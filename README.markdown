machines
=======================================

Setup Ubuntu development and server **machines** for hosting Ruby on Rails 3 applications.

Goals
---------------------------------------

* To make a simple, transparent build tool
* Get going quickly with the standard defaults
  * Ubuntu x64 11.04 (when released)
  * Nginx 8
  * RVM (latest)
  * Passenger 3
  * Ruby on Rails 3
  * MySQL 5
  * Planned
    * Monit, Munin, Sphinx, logrotate
* Easily override defaults with configuration options and custom ruby

I share the belief that development, staging, and production environments should match if not be as close as possible.
I develop on Ubuntu Linux and so it felt natural to have Ubuntu as my server environment.

This tool should make it simple to develop and deploy Ruby on Rails applications on Ubuntu.

Installation and Configuration
---------------------------------------

### Install the gem

        gem install machines

### Generate an example build script

        mkdir machines_example && cd machines_example
        machines generate

This will create the following directory structure:

* machines_example
  * certificates
    * example.com.crt - SSL certificate
    * example.com.key - SSL private key
    * selfsigned.crt - Self-signed SSL certificate
    * selfsigned.key - Self-signed SSL private key
    * amazon.key - Your X.509 private key to access Amazon Web Services
  * config
    * apps.yml - App servers configuration
    * config.yml - EC2 settings, timezone, webserver, database
    * hosts.yml - List of domains to add for local nginx/passenger development to /etc/hosts
    * packages.yml - packages settings (versions, paths, urls etc)
  * mysql
    * dbmaster.cnf
    * dbslave.cnf
  * nginx
    * conf
      * htpasswd
    * app_server.conf.erb
    * initd
    * nginx.conf.erb
  * packages
    * dev_extras.rb (example custom package)
  * users
    * phil
      * basrc
      * confi
  * Machinesfile

### Configure your deployment

1. Edit the build script (`Machinesfile`)
1. Add your certificates and amazon private key
1. Edit files in `config/`
1. Alter, add or remove `nginx`, `mysql` and custom `packages`
1. Setup `users`
1. Add `~/.ssh/id_rsa.pub` public key from users machines to `users/www/authorized_keys` file

### If installing on a development machine
* Make sure you have Bridged Networking setup if using a VM
* Install Ubuntu
* Install SSH Server & note the IP address

    sudo apt-get update && sudo apt-get -y install openssh-server && ifconfig

### Test the Machinesfile

    ssh-keygen -R <host ip> # remove host from known_hosts file (handy when testing)
    machines test <configuration>

### Build the machine

    $ machines build

*machines* will ask a series of questions:

    1. Desktop
    2. Staging
    3. Production
    4. Database
    Select machine to build: 1
    Would you like to start an EC2 instance (y/n)? n
    Enter the IP address of the target machine (EC2, VM, LAN):
    1. phil
    2. www
    Choose user:
    Password:
    Hostname to set machine to (Shown on bash prompt if default .bashrc used):

If not a DB Server:
    Enter the IP address or DNS name of the database this app server will connect to:
    Enter the root password of the database (Used to create permissions for each of the apps):


While running open another terminal to view detailed output:

    tail -f log/output.log

Commandline Options
---------------------------------------
* `htpasswd` - Asks for a username and password and generates basic auth in webserver/conf/htpasswd'
* `generate` - Generates an example machines project'
* `check`    - Checks Machinesfile for syntax issues'
* `test`     - Runs through Machinesfile logging all commands to log/output.log but does not acutally run them'
* `build`    - Asks some questions then builds your chosen machine'

== Warnings
You might see something one of the following while upgrading/installing packages:
    debconf: Unable to initialise frontend: Dialog
    WARNING: Failed to parse default value
    update-rc.d: warning: unattended-upgrades start runlevel arguments

These are all known issues and nothing to worry about

== TODO

* Add :abort => true to abort on failed check
* Add asynchronous ssh so output can be piped live
* Add timer
* Add checking of return values
* More logging needed on initialization

Note on Patches/Pull Requests
---------------------------------------

This project uses *autotest* for continuous testing
Install libnotify-bin on linux to get growl notifications when using *autotest*

* Fork the project.
* Test drive your feature addition or bug fix
* Commit, do not mess with rakefile, version, or history.
* Send me a pull request. Bonus points for topic branches.

Copyright
---------------------------------------

Copyright (c) 2010, 2011 Phil Thompson. See LICENSE for details.

