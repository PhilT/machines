Machines
=======================================

Setup Ubuntu development and server **Machines** locally or on Amazon EC2 for hosting Ruby on Rails 3 applications.

Run commands like:

    sudo install %w(build-essential zlib1g-dev libpcre3-dev)
    sudo install 'git://github.com/gmate/gmate.git', :to => dir, :args => '-n'
    sudo write "127.0.1.1\t#{AppConf.hostname}", :to => '/etc/hosts'
    sudo append "192.168.1.2\tserver", :to => '/etc/hosts'
    run download AppConf.nginx.url
    run create_from 'nginx/nginx.conf.erb', :to => File.join(AppConf.nginx.path, 'conf', 'nginx.conf')

Status
---------------------------------------

It is currently under development but I am very close to rolling out a beta.

`machines dryrun` is now running and generating the commands. Will be testing shortly (Aug 2011)


Features
---------------------------------------

* Preconfigured Ruby & Rails development environment including, Openbox, docky, gEdit with gmate and VirtualBox
* Working default template supports Nginx, RVM, Passenger, Ruby, Rails apps, MySQL (+ replication), Git, Monit, Logrotate
* Easily override the defaults with configuration options and custom ruby
* Several deb sources added making it easier to keep up-to-date with the latest versions
* Tested on Ubuntu i386/amd64 11.04 minimal
* Minimal Ubuntu ISO/IMG used for increased security, stability and speed
* Commands abstracted to provide a consistent configuration syntax
* Full automated test suite to ensure correct commands are generated (Using RSpec)
* Extra checks done to ensure command generates the correct result and avoids false positives (e.g. successful return values)
* A lightweight Ubuntu install


Motivation
---------------------------------------

I believe that development, staging, and production environments should match if not be as close as possible.
I develop on Ubuntu Linux and so it felt natural to have Ubuntu as my server environment. I've spent many years
building and configuring PCs and anything that can be done to automate the process is a good thing in my opinion.
I also like to know what I've got installed so I have little clutter and an optimally running machine. I also like
to reinstall development machines usually when upgrading Ubuntu or adding/changing hardware and prefer a clean start.

There are a few configuration management tools on the market such as Puppet and Chef but they try to cater for every
possible server environment. They also do a very good job of configuration change management. Machines narrows the
scope to a single platform and framework and does not try to manage change, instead opting for reinstallation. As
cloud computing instances can be brought up on a whim, I find this an acceptable compromise to further aid simplicity.


Description
---------------------------------------

This tool should make it simple to develop and deploy Ruby on Rails applications on Ubuntu by providing a build script
with sensible defaults.

The top level script is the `Machinesfile`. This contains the packages to include. Packages contain the commands to
run. Default packages are provided by *machines*. Default packages can be overridden and new ones created. Feel free to
fork *machines* and your add packages. Send a pull request and if they are tested they'll be added to the next release.

Commands are added to a queue with `sudo` or `run`. [Here is a list of the packages](https://github.com/PhilT/machines/tree/master/lib/packages) in *machines*. [TODO: List of commands]


Installation and Configuration
---------------------------------------

### Install the gem

    gem install machines

### Generate an example build script

    machines new <directory>

Running `machines new example` creates the `example` directory and copies in a default template
(a bit like `rails new`).

### Configure your deployment

1. Edit the build script (`Machinesfile`)
1. Add your certificates and amazon private key
1. Edit settings in `config/`
1. Alter, add or remove `nginx`, `mysql` and custom `packages`
1. Setup `users/`
1. Add `~/.ssh/id_rsa.pub` public key from all users machines that need access, to the `users/www/authorized_keys` file

### If installing a development machine

If testing on a VM see **Setting up the test Machines virtual machine** below.

* Download and prepare the Ubuntu USB image. Replace `/dev/sdX` with your USB device name (use dmesg)

  For i386 do:

      wget http://archive.ubuntu.com/ubuntu/dists/natty/main/installer-i386/current/images/netboot/boot.img.gz -O ~/Downloads/Ubuntu11.04_i386.img.gz
      gunzip ~/Downloads/Ubuntu11.04_i386.img.gz
      sudo dd if=~/Downloads/Ubuntu11.04_i386.img of=/dev/sdX

  or for amd64 do:

      wget http://archive.ubuntu.com/ubuntu/dists/natty/main/installer-amd64/current/images/netboot/boot.img.gz -O ~/Downloads/Ubuntu11.04_amd64.img.gz
      gunzip ~/Downloads/Ubuntu11.04_amd64.img.gz
      sudo dd if=~/Downloads/Ubuntu11.04_amd64.img of=/dev/sdX

* Insert the USB stick and boot from it to install Ubuntu
* Install SSH Server & note the IP address

    sudo apt-get update && sudo apt-get -y install openssh-server && ifconfig

### Check the Machinesfile

    ssh-keygen -R <host ip> # remove host from known_hosts file (handy when testing)
    machines dryrun
    cat log/output.log

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

Console output:

* Running commands are displayed in gray
* Tasks show in blue
* Completed commands change to:
* Successfully completed commands are displayed in green
* Failures show in red
* Yellow indicates there was no check for the command

While running open another terminal to view detailed output:

    tail -f output.log


Commandline Options
---------------------------------------

    machines COMMAND
    COMMAND can be:
      htpasswd            - Asks for a username and password and generates basic auth in webserver/conf/htpasswd
      new <DIR>           - Creates a directory called DIR and generates an example machines project in it
      check               - Checks Machinesfile for syntax issues
      dryrun              - Runs through Machinesfile logging all commands to log/output.log but does not acutally run them
      build               - Asks some questions then builds your chosen machine
      build <TASK>        - Builds a single named task
      packages            - lists the available packages
      override <PACKAGE>  - copies the default package into project/packages so it can be edited/overidden


### Rake tasks for managing the VM (these tasks will be turned into commands on Machines to make testing easier)

    rake vm:kill         # Shutdown the virtual machine
    rake vm:restore      # Restore last snapshot of virtual machine
    rake vm:start        # Start the virtual machine in headless mode
    rake vm:state        # Get virtual machine state
    rake vm:stop         # Stop the virtual machine

    rake vm:win:kill     # Shutdown the virtual machine (on a Windows host)
    rake vm:win:restore  # Restore last snapshot of virtual machine (on a Windows host)
    rake vm:win:start    # Start the virtual machine in headless mode (on a Windows host)
    rake vm:win:state    # Get virtual machine state (on a Windows host)
    rake vm:win:stop     # Stop the virtual machine (on a Windows host)

If you have Ubuntu running on a Windows Host you can use the vm:win:* tasks to control the machines VM used for testing.
The simplest program I've found to get a Windows SSH server is freeSSHd (<http://www.freesshd.com/?ctt=download>).


About the Template
---------------------------------------

Default structure created by running `machines new example`:

* example/
  * certificates/
    * example.com.crt - SSL certificate
    * example.com.key - SSL private key
    * selfsigned.crt - Self-signed SSL certificate
    * selfsigned.key - Self-signed SSL private key
    * amazon.key - Your X.509 private key to access EC2. The name (without .key) should match the name on your EC2 account.
  * config/
    * apps.yml - App servers configuration
    * config.yml - EC2 settings, timezone, webserver, database, package settings (versions, paths, urls etc)
    * hosts.yml - List of domains to add for local nginx/passenger development to /etc/hosts
  * mysql/
    * dbmaster.cnf
    * dbslave.cnf
  * nginx/
    * conf
      * htpasswd
    * app_server.conf.erb
    * initd
    * nginx.conf.erb
  * packages/ - Packages with the same name as builtin packages take precedence
    * dev_extras.rb (example custom package)
  * users/
    * phil
      * basrc
      * confi
  * Machinesfile

Global settings
---------------------------------------

*machines* uses a gem I wrote called [app_conf](https://github.com/PhilT/app_conf). It's used to load global settings
from YAML files as well as add further settings in Ruby. *machines* uses both internally and for package settings.
Some of the settings set and used by *machines* are:

* `AppConf.commands` - All the commands that are to be run
* `AppConf.tasks` - Names of the tasks - Used to check dependencies and display tasks the help
* `AppConf.project_dir` - The local project directory, mostly likely the current working directory
* `AppConf.file` - The file logger
* `appConf.console` - The console logger
* `AppConf.user` - The selected user settings

Take a look at `template/config/*.yml` for more.

### Two shortcuts are available to packages.

1. Local relative paths will be from `AppConf.project_dir`
1. Specifying `$HOME/rest/of/path` for a local path expands to `#{AppConf.project_dir}/users/#{AppConf.user.name}/rest/of/path`


Setting up the test Machines virtual machine
---------------------------------------

* Grab the Minimal CD Image

  For i386 do:

      wget http://archive.ubuntu.com/ubuntu/dists/natty/main/installer-i386/current/images/netboot/mini.iso -O ~/Downloads/Ubuntu11.04_i386.iso

  or for amd64 do:

      wget http://archive.ubuntu.com/ubuntu/dists/natty/main/installer-amd64/current/images/netboot/mini.iso -O ~/Downloads/Ubuntu11.04_amd64.iso

* Start your virtualization software (I use VirtualBox).
  * Create a new VM with the name of machinesvm (used in the rake tasks and tests)
  * Select Ubuntu or Ubuntu x64 as the OS (depending on your chosen image)
  * Go to Network and add a Bridged Adapter and a Host-only Adapter
  * Go to Storage, select the Empty CD, click the CD icon on the far right and find the image (in /tmp)
  * I also turn off the Audio device
* Start the VM, select Command line Install and follow the prompts
* Accept default hostname (this will be set later)
* Enter 'user' for username and 'password' for the password
* If desired apply the piix4_smbus error fix(A warning that appears on Ubuntu VMs when booting: May be fixed in 11.04)

      sudo sh -c 'echo blacklist i2c_piix4 >> /etc/modprobe.d/blacklist.conf'

* And add openssh

      sudo apt-get -y install openssh-server && ifconfig

* On your local machine add an entry to the hosts file (change VM_IP_ADDRESS to the ip address of the VM)

      sudo sh -c 'echo VM_IP_ADDRESS machinesvm >> /etc/hosts'

* Finally, take a snapshot of the VM and name it 'Clean'. This is used to restore the VM to a known state after each test run


What's happening under the hood
---------------------------------------

ssh uses the specified user and then sudo is added to commands that require it.
When sudo is needed for file uploads. The file is uploaded to /tmp then sudo cp'd to the destination.
When `package` is called in the `Machinesfile` that file is loaded either from the projects packages directory,
or from the Machines packages if not found in the project.


Limitations
---------------------------------------
* Only one user per machine. Servers use www-data (by default) for nginx/apache, passenger and deployments.
* The system has been designed to allow a certain flexibility in the configuration although some things
  may not yet be totally configurable it should be possible to add or modify the relevant package.
* We are currently focused on Ruby 1.9.2, Rails 3 and Passenger 3.
* Some commands may not properly escape quotes when used with sudo (e.g. append and replace). This may be addressed in a future release.

Planned
---------------------------------------

Supporting versions of Ubuntu from 11.04 onwards is planned.


Warnings
---------------------------------------

[NEED TO CHECK THIS IS STILL HAPPENING]

You might see one of the following while upgrading/installing packages:
    debconf: Unable to initialise frontend: Dialog
    WARNING: Failed to parse default value
    update-rc.d: warning: unattended-upgrades start runlevel arguments

These are known issues and nothing to worry about.


Development, Patches, Pull Requests
---------------------------------------

* Fork the project.
* Test drive your feature addition or bug fix
* Commit, do not mess with rakefile, version, or history.
* Send me a pull request. Please use topic branches.

Currently adding package tests and integration test.
Feel free to add/enhance packages and submit pull requests.


References
---------------------------------------

### APIs

* <http://aws.amazon.com/documentation/>
* <http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/>
* <http://net-ssh.github.com/>
* <http://rdoc.info/github/grempe/amazon-ec2>


### General

* Rails deployment guide: <http://kris.me.uk/2010/11/15/rails3-rvm-passenger3-apache.html>
* Another Rails deployment guide: <http://thoughtsincomputation.com/posts/deploying-in-harmony-capistrano-rvm-bundler-and-git>
* EC2 deployment for Rails with Rubber: <http://ginzametrics.com/deploy-rails-app-to-ec2-with-rubber.html>
* MySQL and EBS: <http://aws.amazon.com/articles/1663>
* Nginx Passenger setup guide: <https://github.com/jnstq/rails-nginx-passenger-ubuntu>
* Nginx init.d script: <http://articles.slicehost.com/2007/10/17/ubuntu-lts-adding-an-nginx-init-script>
* Bundler Deployment: <http://gembundler.com/deploying.html>
* Free SSL Certificates: <http://www.startssl.com/>

### Ubuntu minimal install guides

* <http://wiki.dennyhalim.com/ubuntu-minimal-desktop>
* <http://www.psychocats.net/ubuntu/minimal>
* <https://help.ubuntu.com/community/Installation/LowMemorySystems>

Acknowledgements
---------------------------------------

Thanks to all the people that published the hundreds of articles, blog posts and APIs I've read.


Copyright
---------------------------------------

Copyright (c) 2010, 2011 Phil Thompson. See LICENSE for details.

