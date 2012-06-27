Machines - A custom Ubuntu system in less than 15 minutes
===========================================================

Setup Ubuntu development and server **Machines** locally or in the cloud for developing and hosting Ruby, Rails and related environments.

Run commands like:

    sudo install %w(build-essential zlib1g-dev libpcre3-dev)
    sudo write "127.0.1.1\t#{$conf.hostname}", :to => '/etc/hosts'
    sudo append "192.168.1.2\tserver", :to => '/etc/hosts'
    run download $conf.nginx.url
    run create_from 'nginx/nginx.conf.erb', :to => File.join($conf.nginx.path, 'conf', 'nginx.conf')

Rerun the passenger_nginx install:

    machines build phil_workstation passenger_nginx

Status
-----------------------------------------------------------

(June 2012)

Working development and server builds.

Cloud deployments to complete.

Features
-----------------------------------------------------------

* An opinionated Ubuntu configuration script with sensible defaults
* Easily override the defaults with configuration options and custom ruby
* Supports several cloud services
* Default template supports Nginx, Passenger, Ruby, Rails, MySQL, Git, Monit, Logrotate
* Preconfigured Ruby & Rails light development environment (Openbox or Subtle)
* Bring up new instances fully configured in less than 15 minutes

Motivation
-----------------------------------------------------------

Configuration management is a complex topic. I wanted to reduce some of the variables (single target platform, single development environment) to provide a simpler solution.


Overview
-----------------------------------------------------------

The top level script is the `Machinesfile`. This contains the packages to include. Packages contain the commands to run. Default packages are provided by Machines. Default packages can be overridden and new ones created.

Commands are added to a queue with `sudo` or `run`. [lib/packages](https://github.com/PhilT/machines/tree/master/lib/packages) contains the packages you can add in the `Machinesfile` in Machines. Once the build starts the commands are run and shown with the current progress.

Installation and Configuration
-----------------------------------------------------------

### Install the gem

    gem install machines

### Generate an example build script

    machines new example

Creates the `example` folder and copies in an example template.

### Configure your deployment

Take a look at the generated project. It contains several folders with templates and
configuration settings for various programs, your `Machinesfile` and the various `.yml` files.

`machines.yml` is your machine architecture. Here you'll add all the computers in your environment.

`webapps.yml` lists the web applications you develop and maintain.

`config.yml` contains settings for various packages. Version numbers, Cloud configuration, paths, etc.

`users/` contains user specific preferences, dotfiles, etc

* Create your architecture in `machines.yml`
* Add you webapps in `webapps.yml`
* Edit the build script (`Machinesfile`)
* Add your websites certificates and amazon private key (if required)
* Edit settings in `config.yml`
* Run `machines override <package>` to copy a default package to your project for alteration (Use `machines packages` to see a list)
* Setup your `users/` folders
* Add `~/.ssh/id_rsa.pub` public key from all users machines that need access, to the `users/www/authorized_keys` file

### Prepare the target machine

* Download the latest minimal Ubuntu 12.04 image or ISO (Precise Pangolin)
  * [64bit image](http://archive.ubuntu.com/ubuntu/dists/precise/main/installer-amd64/current/images/netboot/boot.img.gz)
  * [64bit ISO](http://archive.ubuntu.com/ubuntu/dists/precise/main/installer-amd64/current/images/netboot/mini.iso)
  * [32bit image](http://archive.ubuntu.com/ubuntu/dists/precise/main/installer-i386/current/images/netboot/boot.img.gz)
  * [32bit ISO](http://archive.ubuntu.com/ubuntu/dists/precise/main/installer-i386/current/images/netboot/mini.iso)
* Images can be written to USB with (Be sure to eject the drive correctly):
* `gunzip boot.img.gz && sudo dd if=boot.img of=/dev/sdX` where `sdX` is your USB device (use `dmesg` to get this)
* Insert the USB stick and boot from it to install Ubuntu
* Install SSH Server & note the IP address

    sudo apt-get update && sudo apt-get -y install openssh-server && ifconfig

### Check the Machinesfile

    machines dryrun <machine>
    cat log/output.log


### Check the machine

    ssh-keygen -R <host ip> # remove host from known_hosts file (handy when testing)
    $ ssh <IP ADDRESS>      # Make sure you can connect to the machine


### Build the machine

    $ machines build <machine>


Console output:

* Running commands are displayed in gray
* Tasks show in blue
* Successfully completed commands are displayed in green
* Failures show in red
* Yellow indicates there was no check for the command

While running open another terminal to view detailed output:

    tail -f output.log


Commandline Options
-----------------------------------------------------------

    machines COMMAND
    COMMAND can be:
      htpasswd                 Generates basic auth in webserver/conf/htpasswd
      new <DIR>                Generates an example machines project in DIR
      dryrun                   Logs commands but does not run them
      tasks                    Lists the available tasks
      build <machine> [task]   Builds your chosen machine. Optionally, build just one task
      packages                 Lists the available packages
      override <PACKAGE>       Copies the default package into project/packages so it can be edited/overidden


Global settings
-----------------------------------------------------------

Machines uses a gem I wrote called [app_conf](https://github.com/PhilT/app_conf). It allows settings
to be loaded from YAML and also set using Ruby. Machines uses it both internally and for package settings.
Some of the settings set and used by Machines are:

* `$conf.appsroot` - Where applications are cloned
* `$conf.commands` - All the commands that are to be run
* `$conf.environment` - Environment of the machine (also at `$conf.machine.environment`)
* `$conf.machine` - Configuration for the selected machine
* `$conf.machine_name` - Name of the selected machine
* `$conf.roles` - List of roles for selected machine (also available as `$conf.machine.roles`)
* `$conf.tasks` - Names of the tasks - Used to check dependencies and display tasks the help
* `$conf.user` - The selected user name
* `$conf.user_home` - Users home folder e.g. `/home/phil`
* `$conf.users` - A list of the available users
* `$conf.webapps` - A hash of webapps keyed from the name of the webapp specified in webapps.yml

Take a look at `template/*.yml` for more.


Setting up a test VM
-----------------------------------------------------------

Make sure you've downloaded one of the ISOs from the list in *Prepare the target machine*.

1. Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
1. Oracle VirtualBox -> New
  * Name: machinesvm
  * Operating System: Linux
  * Version: Ubuntu (64 bit)
1. Settings -> Network -> Adapter 2 -> Enable Network Adapter
  * Attached to: Host-only Adapter
1. Start -> Media Source Folder Icon -> mini.iso
1. Installer boot menu -> Install -> Accept defaults except for:
  * eth0 primary interface
  * Full name for the new user: user
  * Username for your account: user
  * Choose a password for the new user: password
  * Re-enter password to verify: password
  * YES to partition disks (choose partition entire disk if asked)
  * Add OpenSSH from application installer menu
1. Devices -> CD/DVD Devices -> Uncheck mini.iso
1. Reboot
  * ubuntu Login: user
  * Password: password
1. Run `ifconfig` and make a note of eth1 inet addr
1. Take a snapshot (restore before each test run)


What's happening under the hood
-----------------------------------------------------------

* An ssh connection is established to send all commands and uploads
* Ssh uses the specified user and then sudo is added to commands that require it
* When sudo is needed for file uploads. The file is uploaded to /tmp then sudo cp'd to the destination
* When `package` is called in the `Machinesfile` that file is loaded either from the projects packages folder
  or from the Machines packages if not found in the project


Limitations
-----------------------------------------------------------
* Only one user per machine. Although other users could be setup with additional build runs.
* One environment per machine - Again additional machines could be configured to use the same physical machine (although could be problems with some environment settings)
* Servers use www (by default) for nginx/apache, passenger and deployments
* The system has been designed to allow a certain flexibility in the configuration although some things
  may not yet be totally configurable it should be possible to add or modify the relevant package
* We are currently focused on Ruby 1.9.2 (Moving to 1.9.3 soon), Rails 3 and Passenger 3
* Some commands may not properly escape quotes when used with sudo (e.g. append and replace). This may be addressed in a future release


Development, Patches, Pull Requests
-----------------------------------------------------------

* Fork the project
* Test drive your feature addition or bug fix
* Commit, do not mess with Rakefile, version, or history
* Send me a pull request. Please use topic branches
* Feel free to add/enhance packages and submit pull requests
* Package tests are a bit of a pain but do catch a lot of potential issues


References
-----------------------------------------------------------

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
* Nginx, passenger manual compile: <http://extralogical.net/articles/howto-compile-nginx-passenger.html>
* Nginx Passenger setup guide: <https://github.com/jnstq/rails-nginx-passenger-ubuntu>
* Nginx configuration: <http://articles.slicehost.com/2009/3/5/ubuntu-intrepid-nginx-configuration>
* Bundler Deployment: <http://gembundler.com/deploying.html>


### RVM

* Multiple gemsets in passenger <http://blog.ninjahideout.com/posts/the-path-to-better-rvm-and-passenger-integration>
* Nginx and Passenger <http://blog.ninjahideout.com/posts/a-guide-to-a-nginx-passenger-and-rvm-server>

### Ubuntu minimal install guides

* <http://wiki.dennyhalim.com/ubuntu-minimal-desktop>
* <http://www.psychocats.net/ubuntu/minimal>
* <https://help.ubuntu.com/community/Installation/LowMemorySystems>

Acknowledgements
-----------------------------------------------------------

Thanks to all the people that published the hundreds of articles, blog posts and APIs I've read.


Copyright
-----------------------------------------------------------

Copyright (c) 2010, 2011, 2012 Phil Thompson. See LICENSE for details.

