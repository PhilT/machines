Machines
=======================================

Setup Ubuntu development and server **Machines** for hosting Ruby on Rails 3 applications.

Status
---------------------------------------

This is the second major version. The first was more of a proof of concept and it worked. This version is
much more flexible and extendable. Much better documented and easier (I hope) to get started. It is currently
under development but we are very close to rolling out a beta.

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

I believe that development, staging, and production environments should match if not be as close as possible.
I develop on Ubuntu Linux and so it felt natural to have Ubuntu as my server environment. I spent many years
building and configuring PCs and anything that makes the job easier is a good thing in my opinion.

This tool should make it simple to develop and deploy Ruby on Rails applications on Ubuntu by providing sensible
defaults in a template build script, the `Machinesfile` and associated `package` files.

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
1. Setup `users/`
1. Add `~/.ssh/id_rsa.pub` public key from all users machines that need access, to the `users/www/authorized_keys` file

### If installing on a development machine
* Make sure you have Bridged Networking setup if using a VM
* Install Ubuntu
* Install SSH Server & note the IP address

    sudo apt-get update && sudo apt-get -y install openssh-server && ifconfig

(See Setting up the test Machines VM further down for more info)

### Check the Machinesfile

    ssh-keygen -R <host ip> # remove host from known_hosts file (handy when testing)
    machines check
    machines dryrun

### Build the machine

    $ machines build

**Machines** will ask a series of questions:

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
* `dryrun`   - Runs through Machinesfile logging all commands to log/output.log but does not acutally run them'
* `build`    - Asks some questions then builds your chosen machine'

Setting up the test Machines VM
---------------------------------------

https://help.ubuntu.com/community/Installation/LowMemorySystems

* Grab the Minimal CD Image from https://help.ubuntu.com/community/Installation/MinimalCD (I tend to go for x64)
* For the VM I use VirtualBox.
  * Create a new VM with the name of machinesvm (used in the rake tasks)
  * Select Ubuntu or Ubuntu x64 as the OS (depending on your chosen image)
  * Go to Network and set Bridged Adapter
  * Go to Storage, select the Empty CD, click the CD icon on the far right and find the image
  * I also turn off the Audio device
* Start the VM, select Command line Install and follow the prompts
* Accept default hostname (this will be set later)
* Enter 'user' for username and 'password' for the password
* If desired apply the piix4_smbus error fix(A warning that appears on Ubuntu VMs when booting)
    sudo sh -c 'echo blacklist i2c_piix4 >> /etc/modprobe.d/blacklist.conf'
* And add openssh
    sudo apt-get -y install openssh-server && ifconfig
* On your local machine (change VM_IP_ADDRESS to the ip address of the VM)
    sudo sh -c 'echo VM_IP_ADDRESS machinesvm >> /etc/hosts'
* What I also do at this point is take a snapshot of the VM

There are also some rake tasks for starting and stopping the vm.

What's happening under the hood
---------------------------------------

ssh uses the specified user and then sudo is added to commands that require it.
When sudo is needed for file uploads. The file is uploaded to /tmp then sudo cp'd to the destination.
When `package` is called in the `Machinesfile` that file is loaded either from the local, custom packages
directory or from the Machines packages.

Limitations
---------------------------------------
* Only one user per machine. SSH logs in as that user and there is currently no way to change it. Multiple
  users is not something we currently need and has therefore been made a low priority.
* The system has been designed to allow a certain flexibility in the configuration although some things
  may not yet be totally configurable it should be possible to add or modify a relevant package. For
  example, app settings allow different servers to have different apps setup on them. This however has
  not yet been exercised.

Warnings
---------------------------------------

[NEED TO CHECK THIS IS STILL HAPPENING]

You might see one of the following while upgrading/installing packages:
    debconf: Unable to initialise frontend: Dialog
    WARNING: Failed to parse default value
    update-rc.d: warning: unattended-upgrades start runlevel arguments

These are all known issues and nothing to worry about.

TODO
---------------------------------------

* Add :abort => true to abort on failed check
* Add asynchronous ssh so output can be piped live
* Add timer
* Add checking of return values
* More logging needed on initialization

Note on Patches/Pull Requests
---------------------------------------

This project uses *watchr* for continuous testing.
It's fast and very configurable. The script approximates autotest behaviour.
It've also added an option to only run the spec/code being worked on.
    watchr .watchr

* Fork the project.
* Test drive your feature addition or bug fix
* Commit, do not mess with rakefile, version, or history.
* Send me a pull request. Please use topic branches.

Copyright
---------------------------------------

Copyright (c) 2010, 2011 Phil Thompson. See LICENSE for details.

