require 'spec_helper'

describe 'Installation' do
  include Machines::Core
  include Machines::Installation
  include Machines::Configuration

  describe 'add_source' do
    it 'should add to /etc/apt/sources and add a key' do
      add_source 'name', 'source', :gpg => 'gpg'
      AppConf.commands.map(&:command).should == ["export TERM=linux && echo 'deb source' >> /etc/apt/sources.list.d/name.list", 'export TERM=linux && wget -q -O - gpg | apt-key add -']
    end

    it 'should write to alternate file specified' do
      add_source 'name', 'source', :gpg => 'gpg', :to => 'altname'
      AppConf.commands.map(&:command).should == ["export TERM=linux && echo 'deb source' >> /etc/apt/sources.list.d/altname.list", 'export TERM=linux && wget -q -O - gpg | apt-key add -']
    end
  end

  describe 'add_ppa' do
    it 'should add a ppa' do
      add_ppa 'user/name', 'key'
      AppConf.commands.map(&:command).should == ['export TERM=linux && add-apt-repository ppa:user/name']
    end
  end

  describe 'update' do
    it 'should add a command to upgrade apt' do
      update
      AppConf.commands.map(&:command).should == [
        'export TERM=linux && export DEBIAN_FRONTEND=noninteractive && apt-get -q -y update',
        'export TERM=linux && export DEBIAN_FRONTEND=noninteractive && apt-get -q -y upgrade',
        'export TERM=linux && export DEBIAN_FRONTEND=noninteractive && apt-get -q -y autoremove',
        'export TERM=linux && export DEBIAN_FRONTEND=noninteractive && apt-get -q -y autoclean'
      ]
    end
  end

  describe 'install' do
    it 'should add a command to install from an install script' do
      should_receive(:required_options).with({:to => '~/installer'}, [:to])
      install 'git://url', :to => '~/installer'
      AppConf.commands.map(&:command).should == ['export TERM=linux && rm -rf ~/installer && git clone git://url ~/installer && cd ~/installer && find . -maxdepth 1 -name install* | xargs -I xxx bash xxx ']
    end

    it 'should add a command to install apt packages' do
      install %w(package1 package2)
      AppConf.commands.map(&:command).should == [
        'export TERM=linux && export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install package1',
        'export TERM=linux && export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install package2'
      ]
    end

    it 'should add commands to download, install and remove a package ' do
      install "http://some.url/package_name.deb", nil
      AppConf.commands.map(&:command).should == ['export TERM=linux && cd /tmp && wget http://some.url/package_name.deb && dpkg -i package_name.deb && rm package_name.deb && cd -']
    end
  end

  describe 'uninstall' do
    it 'should uninstall a package' do
      uninstall %w(apackage)
      AppConf.commands.map(&:command).should == ['export TERM=linux && export DEBIAN_FRONTEND=noninteractive && apt-get -q -y remove apackage']
    end
  end

  describe 'gem' do
    it 'should add a command to install a gem' do
      gem 'package'
      AppConf.commands.map(&:command).should == ['export TERM=linux && gem install package']
    end

    it 'should add a command to install a gem with a specified version' do
      gem 'package', :version => '1'
      AppConf.commands.map(&:command).should == ["export TERM=linux && gem install package -v '1'"]
    end
  end

  describe 'gem_update' do
    it 'should add a command to update gems' do
      gem_update 'gem'
      AppConf.commands.map(&:command).should == ['export TERM=linux && gem update gem']
    end
  end

  describe 'extract' do
    it 'should add commands to download, extract and remove an archive' do
      extract 'http://url/package'
      AppConf.commands.map(&:command).should == ['export TERM=linux && cd /tmp && wget http://url/package && tar -zxf package && rm package && cd -']
    end

    it 'should add commands to download, extract and remove a zip archive' do
      extract 'http://url/package.zip'
      AppConf.commands.map(&:command).should == ['export TERM=linux && cd /tmp && wget http://url/package.zip && unzip -qq package.zip && rm package.zip && cd -']
    end
  end

  describe 'git_clone' do
    it 'should add a command to clone a git repository' do
      git_clone 'http://git_url.git'
      AppConf.commands.map(&:command).should == ['export TERM=linux && git clone -q http://git_url.git ']
    end

    it 'should add a command to clone a git repository to a specified folder' do
      git_clone 'http://git_url.git', :to => 'dir'
      AppConf.commands.map(&:command).should == ['export TERM=linux && git clone -q http://git_url.git dir']
    end
  end
end

