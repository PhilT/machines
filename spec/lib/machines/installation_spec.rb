require 'spec_helper'

describe 'Installation' do
  include Machines::Core
  include Machines::Installation
  include Machines::Configuration

  describe 'add_ppa' do
    it 'adds a ppa' do
      subject = add_ppa 'user/name', 'key'
      subject.map(&:command).must_equal ['add-apt-repository ppa:user/name', 'apt-get -q -y update > /tmp/apt-update.log']
    end
  end

  describe 'deb' do
    it 'adds to /etc/apt/sources and add a key' do
      subject = deb 'source', :key => 'gpg', :name => 'name'
      subject.map(&:command).must_equal [
        "echo deb source >> /etc/apt/sources.list",
        "wget -q gpg -O - | apt-key add -",
        "apt-get -q -y update > /tmp/apt-update.log"
      ]
      subject.map(&:check).must_equal [
        "grep \"source\" /etc/apt/sources.list #{echo_result}",
        "apt-key list | grep -i name #{echo_result}",
        "grep \"Reading package lists\" /tmp/apt-update.log #{echo_result}"
      ]
    end

    it 'modifies echo command to grab the distribution name to be used in the source' do
      subject = deb 'source YOUR_UBUNTU_VERSION_HERE', :key => 'gpg', :name => 'name'
      subject.first.command.must_equal 'expr substr `cat /etc/lsb-release | grep DISTRIB_CODENAME` 18 20 | xargs -I YOUR_UBUNTU_VERSION_HERE echo deb source YOUR_UBUNTU_VERSION_HERE >> /etc/apt/sources.list'
    end
  end

  describe 'debconf' do
    it 'sends args to debconf-set-selections' do
      subject = debconf 'app', 'setting', 'boolean', true
      subject.command.must_equal 'echo app setting boolean true | debconf-set-selections'
    end
  end

  describe 'extract' do
    it 'instaniates commands to download, extract and remove a tar.gz archive' do
      subject = extract 'http://url/package.tar.gz'
      subject.command.must_equal 'cd /usr/local/src && wget http://url/package.tar.gz && tar -xfz package.tar.gz && rm package.tar.gz && cd -'
      subject.check.must_equal 'test -d /usr/local/src/package && echo CHECK PASSED || echo CHECK FAILED'
    end

    it 'instaniates commands to download, extract and remove a tar.bz2 archive' do
      subject = extract 'http://url/package.tar.bz2'
      subject.command.must_equal 'cd /usr/local/src && wget http://url/package.tar.bz2 && tar -xfj package.tar.bz2 && rm package.tar.bz2 && cd -'
      subject.check.must_equal 'test -d /usr/local/src/package && echo CHECK PASSED || echo CHECK FAILED'
    end

    it 'instaniates commands to download, extract and remove a tar archive' do
      subject = extract 'http://url/package.tar.gz'
      subject.command.must_equal 'cd /usr/local/src && wget http://url/package.tar.gz && tar -xfz package.tar.gz && rm package.tar.gz && cd -'
      subject.check.must_equal 'test -d /usr/local/src/package && echo CHECK PASSED || echo CHECK FAILED'
    end

    it 'instaniates commands to download, extract and remove a zip archive' do
      subject = extract 'http://url/package.zip'
      subject.command.must_equal 'cd /usr/local/src && wget http://url/package.zip && unzip -qq package.zip && rm package.zip && cd -'
      subject.check.must_equal 'test -d /usr/local/src/package && echo CHECK PASSED || echo CHECK FAILED'
    end

    it 'moves extracted contents to specified folder' do
      subject = extract 'http://url/package-1.0.tar.gz', :to => '/opt'
      subject.command.must_equal 'cd /opt && wget http://url/package-1.0.tar.gz && tar -xfz package-1.0.tar.gz && rm package-1.0.tar.gz && cd -'
      subject.check.must_equal 'test -d /opt/package-1.0 && echo CHECK PASSED || echo CHECK FAILED'
    end
  end

  describe 'gem' do
    it 'instaniates a command to install a gem' do
      subject = gem 'package'
      subject.command.must_equal 'gem install package'
    end

    it 'instaniates a command to install a gem with a specified version' do
      subject = gem 'package', :version => '1'
      subject.command.must_equal "gem install package -v \"1\""
    end
  end

  describe 'gem_update' do
    it 'instaniates a command to update gems' do
      subject = gem_update 'gem'
      subject.command.must_equal 'gem update gem'
    end
  end

  describe 'git_clone' do
    it 'instaniates a command to clone a git repository' do
      subject = git_clone 'http://git_url.git'
      subject.command.must_equal 'test -d git_url && (cd git_url && git pull) || git clone --quiet http://git_url.git'
    end

    it 'instaniates a command to clone a git repository to a specified folder' do
      subject = git_clone 'http://git_url.git', :to => 'dir'
      subject.command.must_equal 'test -d dir && (cd dir && git pull) || git clone --quiet http://git_url.git dir'
    end

    it 'raises when no url supplied' do
      lambda { git_clone '' }.must_raise ArgumentError
      lambda { git_clone nil }.must_raise ArgumentError
    end

    describe ':branch option' do
      it 'clones to a specific branch' do
        subject = git_clone 'http://git_url.git', :branch => 'other'
        subject.command.must_equal 'test -d git_url && (cd git_url && git pull) || git clone --quiet --branch other http://git_url.git'
      end
    end

    describe ':tag option' do
      it 'checks out a specific tag' do
        subject = git_clone 'http://git_url.git', :to => 'dir', :tag => 'v1.0'
        subject.map(&:command).must_equal [
          'test -d dir && (cd dir && git pull) || git clone --quiet http://git_url.git dir',
          'cd dir && git checkout v1.0'
        ]
      end

      it 'raises when no dir' do
        lambda { git_clone 'http://git_url.git', :tag => 'v1.0' }.must_raise ArgumentError
      end
    end
  end

  describe 'install instaniates commands to' do
    it 'download, extract and link to binary executable' do
      subject = install 'http://some.url/package_name.tar.bz2', :bin => 'package'
      subject.map(&:command).must_equal [
        'cd /tmp && wget http://some.url/package_name.tar.bz2 && tar -xfj package_name.tar.bz2 && rm package_name.tar.bz2 && cd -',
        'mv -f /tmp/package_name /usr/local/lib',
        'ln -sf /usr/local/lib/package_name/package /usr/local/bin/package'
      ]
    end

    it 'download, install and remove a DEB package ' do
      subject = install "http://some.url/package_name.deb"
      subject.map(&:command).must_equal [
        'cd /tmp && wget http://some.url/package_name.deb && dpkg -i --force-architecture package_name.deb && rm package_name.deb && cd -'
      ]
    end

    it 'download, extract, install and remove a group of DEB packages ' do
      subject = install "http://some.url/package_name.tar.gz", :as => :dpkg
      subject.map(&:command).must_equal [
        'cd /tmp && wget http://some.url/package_name.tar.gz && tar -xfz package_name.tar.gz && rm package_name.tar.gz && cd -',
        'cd /tmp/package_name && dpkg -i --force-architecture *.deb && cd - && rm -rf /tmp/package_name'
      ]
    end

    it 'install a single apt package' do
      subject = install 'package1'
      subject.map(&:command).must_equal ['apt-get -q -y install package1']
    end

    it 'install multiple apt packages' do
      subject = install %w(package1 package2)
      subject.map(&:command).must_equal [
        'apt-get -q -y install package1',
        'apt-get -q -y install package2'
      ]
    end
  end

  describe 'uninstall' do
    it 'instaniates a command to uninstall a package' do
      subject = uninstall %w(apackage)
      subject.map(&:command).must_equal ['apt-get -q -y purge apackage']
    end
  end

  describe 'update' do
    it 'instaniates a command to update apt' do
      subject = update
      subject.command.must_equal 'apt-get -q -y update > /tmp/apt-update.log'
    end
  end

  describe 'upgrade' do
    it 'instaniates a command to upgrade apt' do
      subject = upgrade
      subject.map(&:command).must_equal [
        'apt-get -q -y update',
        'apt-get -q -y upgrade',
        'apt-get -q -y autoremove',
        'apt-get -q -y autoclean'
      ]
    end
  end
end

