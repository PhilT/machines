require 'spec_helper'

describe 'Installation' do
  include Machines::Core
  include Machines::Installation
  include Machines::Configuration
  include FakeFS::SpecHelpers

  describe 'add_source' do
    it 'should add to /etc/apt/sources and add a key' do
      subject = add_source 'name', 'source', :gpg => 'gpg'
      subject.map(&:command).should == [
        "echo 'deb source' >> /etc/apt/sources.list.d/name.list",
        "wget -q -O - gpg | apt-key add -"
      ]
    end

    it 'should write to alternate file specified' do
      subject = add_source 'name', 'source', :gpg => 'gpg', :to => 'altname'
      subject.map(&:command).should == [
        "echo 'deb source' >> /etc/apt/sources.list.d/altname.list",
        'wget -q -O - gpg | apt-key add -'
      ]
    end
  end

  describe 'add_ppa' do
    it 'should add a ppa' do
      subject = add_ppa 'user/name', 'key'
      subject.command.should == 'add-apt-repository ppa:user/name'
    end
  end

  describe 'update' do
    it 'should add a command to upgrade apt' do
      subject = update
      subject.map(&:command).should == [
        'export DEBIAN_FRONTEND=noninteractive && apt-get -q -y update',
        'export DEBIAN_FRONTEND=noninteractive && apt-get -q -y upgrade',
        'export DEBIAN_FRONTEND=noninteractive && apt-get -q -y autoremove',
        'export DEBIAN_FRONTEND=noninteractive && apt-get -q -y autoclean'
      ]
    end
  end

  describe 'install' do
    it 'should add a command to install from an install script' do
      should_receive(:required_options).with({:to => '~/installer'}, [:to])
      subject = install 'git://url', :to => '~/installer'
      subject.command.should == 'rm -rf ~/installer && git clone git://url ~/installer && cd ~/installer && find . -maxdepth 1 -name install* | xargs -I xxx bash xxx '
    end

    it 'should add a command to install apt packages' do
      subject = install %w(package1 package2)
      subject.map(&:command).should == [
        'export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install package1',
        'export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install package2'
      ]
    end

    it 'should add commands to download, install and remove a package ' do
      subject = install "http://some.url/package_name.deb", nil
      subject.command.should == 'cd /tmp && wget http://some.url/package_name.deb && dpkg -i package_name.deb && rm package_name.deb && cd -'
    end
  end

  describe 'uninstall' do
    it 'should uninstall a package' do
      subject = uninstall %w(apackage)
      subject.map(&:command).should == ['export DEBIAN_FRONTEND=noninteractive && apt-get -q -y remove apackage']
    end
  end

  describe 'gem' do
    it 'should add a command to install a gem' do
      subject = gem 'package'
      subject.command.should == 'gem install package'
    end

    it 'should add a command to install a gem with a specified version' do
      subject = gem 'package', :version => '1'
      subject.command.should == "gem install package -v '1'"
    end
  end

  describe 'gem_update' do
    it 'should add a command to update gems' do
      subject = gem_update 'gem'
      subject.command.should == 'gem update gem'
    end
  end

  describe 'extract' do
    it 'should add commands to download, extract and remove an archive' do
      subject = extract 'http://url/package'
      subject.command.should == 'cd /tmp && wget http://url/package && tar -zxf package && rm package && cd -'
    end

    it 'should add commands to download, extract and remove a zip archive' do
      subject = extract 'http://url/package.zip'
      subject.command.should == 'cd /tmp && wget http://url/package.zip && unzip -qq package.zip && rm package.zip && cd -'
    end
  end

  describe 'git_clone' do
    it 'should add a command to clone a git repository' do
      subject = git_clone 'http://git_url.git'
      subject.command.should == 'git clone -q http://git_url.git '
    end

    it 'should add a command to clone a git repository to a specified folder' do
      subject = git_clone 'http://git_url.git', :to => 'dir'
      subject.command.should == 'git clone -q http://git_url.git dir'
    end
  end
end

