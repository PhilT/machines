Adding new packages
=======================================

It's easy to add new packages if you need something new on your current install.
I added the following to `packages/printer.rb`:

    task :printer, 'Install Samsung Unified Linux Drivers' do
      sudo deb 'http://www.bchemnet.com/suldr/ debian extra', :key => 'http://www.bchemnet.com/suldr/suldr.gpg', :name => 'Samsung'
      sudo install 'samsungmfp-data'
    end

I added it to my `Machinesfile`:

    package :printer

Then ran it locally:

    machines build task=printer machine=Desktop host=localhost user=phil hostname=ignored

Now the drivers for my printer are installed.


Running individual tasks
=======================================

Here is an example of upgrading Ruby, passenger and Nginx. First we check what commands will be run with the `dryrun` command. This particular time I was upgrading to Ruby 1.9.3-p194 and the latest passenger (3.0.17) and Nginx (1.2.3).

    machines dryrun phil rbenv passenger passenger_nginx nginx webapps
    cat log/output.log

    2% SUDO   apt-get -q -y install git-core
    4% SUDO   apt-get -q -y install curl
    5% RUN    test -d ruby-build && (cd ruby-build && git pull) || git clone --quiet git://github.com...
    7% SUDO   cd ~/ruby-build && ./install.sh
    ...

We can see that git and curl are installed as part of the rbenv install (although they will be ignored as they're already installed). the latest ruby-build is then pulled as it's already on the machine and the installer run.

All looks good so we'll run the build:

    machines build phil rbenv passenger passenger_nginx nginx webapps

Everything gets reinstalled and reconfigured and we can carry on. `sudo restart nginx` may be required.
