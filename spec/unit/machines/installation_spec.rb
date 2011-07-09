require 'spec_helper'

describe 'Installation' do
  include Machines::Core
  include Machines::Installation
  include Machines::Configuration

  describe 'deb' do
    it 'should add to /etc/apt/sources and add a key' do
      subject = deb 'source', :key => 'gpg', :name => 'name'
      subject.map(&:command).should == [
        "echo deb source >> /etc/apt/sources.list",
        "wget -q gpg -O - | apt-key add -"
      ]
      subject.map(&:check).should == [
        "grep \"source\" /etc/apt/sources.list #{echo_result}",
        "apt-key list | grep -i name #{echo_result}"
      ]
    end

    it 'modifies echo command to grab the distribution name to be used in the source' do
      subject = deb 'source DISTRIB_CODENAME', :key => 'gpg', :name => 'name'
      subject.first.command.should == 'expr substr `cat /etc/lsb-release | grep DISTRIB_CODENAME` 18 20 | xargs -I DISTRIB_CODENAME echo deb source DISTRIB_CODENAME >> /etc/apt/sources.list'
    end
  end

  describe 'add_ppa' do
    it 'should add a ppa' do
      subject = add_ppa 'user/name', 'key'
      subject.command.should == 'add-apt-repository ppa:user/name'
    end
  end

  describe 'update' do
    it 'instaniates a command to update apt' do
      subject = update
      subject.command.should == 'export DEBIAN_FRONTEND=noninteractive && apt-get -q -y update'
    end
  end

  describe 'upgrade' do
    it 'instaniates a command to upgrade apt' do
      subject = upgrade
      subject.map(&:command).should == [
        'export DEBIAN_FRONTEND=noninteractive && apt-get -q -y update',
        'export DEBIAN_FRONTEND=noninteractive && apt-get -q -y upgrade',
        'export DEBIAN_FRONTEND=noninteractive && apt-get -q -y autoremove',
        'export DEBIAN_FRONTEND=noninteractive && apt-get -q -y autoclean'
      ]
    end
  end

  describe 'install' do
    it 'instaniates a command to install from an install script' do
      should_receive(:required_options).with({:to => '~/installer'}, [:to])
      subject = install 'git://url', :to => '~/installer'
      subject.command.should == 'rm -rf ~/installer && ' +
        'git clone git://url ~/installer && ' +
        'cd ~/installer && ' +
        'find . -maxdepth 1 -name install* | xargs -I xxx bash xxx '
    end

    it 'instaniates commands to download, install and remove a package ' do
      subject = install "http://some.url/package_name.deb", nil
      subject.command.should == 'cd /tmp && wget http://some.url/package_name.deb && dpkg -i package_name.deb && rm package_name.deb && cd -'
    end

    it 'instaniates a command to install a single apt package' do
      subject = install 'package1'
      subject.map(&:command).should == ['export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install package1']
    end

    it 'instaniates a command to install multiple apt packages' do
      subject = install %w(package1 package2)
      subject.map(&:command).should == [
        'export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install package1',
        'export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install package2'
      ]
    end
  end

  describe 'uninstall' do
    it 'instaniates a command to uninstall a package' do
      subject = uninstall %w(apackage)
      subject.map(&:command).should == ['export DEBIAN_FRONTEND=noninteractive && apt-get -q -y remove apackage']
    end
  end

  describe 'gem' do
    it 'instaniates a command to install a gem' do
      subject = gem 'package'
      subject.command.should == 'gem install package'
    end

    it 'instaniates a command to install a gem with a specified version' do
      subject = gem 'package', :version => '1'
      subject.command.should == "gem install package -v \"1\""
    end
  end

  describe 'gem_update' do
    it 'instaniates a command to update gems' do
      subject = gem_update 'gem'
      subject.command.should == 'gem update gem'
    end
  end

  describe 'extract' do
    it 'instaniates commands to download, extract and remove an archive' do
      subject = extract 'http://url/package'
      subject.command.should == 'cd /tmp && wget http://url/package && tar -zxf package && rm package && cd -'
    end

    it 'instaniates commands to download, extract and remove a zip archive' do
      subject = extract 'http://url/package.zip'
      subject.command.should == 'cd /tmp && wget http://url/package.zip && unzip -qq package.zip && rm package.zip && cd -'
    end
  end

  describe 'git_clone' do
    it 'instaniates a command to clone a git repository' do
      subject = git_clone 'http://git_url.git'
      subject.command.should == 'git clone -q http://git_url.git '
    end

    it 'instaniates a command to clone a git repository to a specified folder' do
      subject = git_clone 'http://git_url.git', :to => 'dir'
      subject.command.should == 'git clone -q http://git_url.git dir'
    end
  end
end

