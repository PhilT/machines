require 'spec_helper'

describe 'Installation' do
  include Machines::Installation
  include Machines::Configuration
  include FakeAddHelper

  describe 'add_source' do
    it 'should add to /etc/apt/sources and add a key' do
      add_source 'name', 'source', :gpg => 'gpg'
      @added.should == ["echo 'deb source' >> /etc/apt/sources.list.d/name.list", 'wget -q -O - gpg | apt-key add -']
    end

    it 'should write to alternate file specified' do
      add_source 'name', 'source', :gpg => 'gpg', :to => 'altname'
      @added.should == ["echo 'deb source' >> /etc/apt/sources.list.d/altname.list", 'wget -q -O - gpg | apt-key add -']
    end
  end

  describe 'add_ppa' do
    it 'should add a ppa' do
      add_ppa 'user', 'name', 'key'
      @added.should == ['add-apt-repository ppa:user/name']
    end
  end

  describe 'update' do
    it 'should add a command to upgrade apt' do
      update
      @added.should == [
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
      @added.should == ['export TERM=linux && rm -rf ~/installer && git clone git://url ~/installer && cd ~/installer && find . -maxdepth 1 -name install* | xargs -I xxx bash xxx ']
    end

    it 'should add a command to install from an install script as a specified user' do
      should_receive(:required_options).with({:to => '~/installer', :as => 'user', :args => 'args'}, [:to])
      install 'git://url', :to => '~/installer', :as => 'user', :args => 'args'
      @added.should == ["su - user -c 'export TERM=linux && rm -rf ~/installer && git clone git://url ~/installer && cd ~/installer && find . -maxdepth 1 -name install* | xargs -I xxx bash xxx args'"]
    end

    it 'should add a command to install apt packages' do
      install %w(package1 package2)
      @added.should == ['export TERM=linux && export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install package1 package2']
    end

    it 'should add commands to download, install and remove a package ' do
      install "http://some.url/package_name.deb"
      @added.should == ['export TERM=linux && cd /tmp && wget http://some.url/package_name.deb && dpkg -i package_name.deb && rm package_name.deb && cd -']
    end
  end

  describe 'uninstall' do
    it 'should uninstall a package' do
      uninstall %w(apackage)
      @added.should == ['export TERM=linux && export DEBIAN_FRONTEND=noninteractive && apt-get -q -y remove apackage']
    end
  end

  describe 'run' do
    it 'should run and check a command' do
      run 'command', :check => 'it worked'
      @added.should == ['export TERM=linux && command']
      @checks.should == ['it worked']
    end

    it 'should run several commands' do
      run ['run this', 'then this']
      @added.should == ['export TERM=linux && run this && then this']
    end

    it 'should run a command as a user' do
      run 'command', :as => 'someone'
      @added.should == ["su - someone -c 'export TERM=linux && command'"]
    end

    it 'should run several commands as a user' do
      run ['run this', 'then this'], :as => 'someone'
      @added.should == ["su - someone -c 'export TERM=linux && run this && then this'"]
    end

    it 'should run several commands as a user and check it worked' do
      run ['run this', 'then this'], :as => 'someone', :check => 'it worked'
      @added.should == ["su - someone -c 'export TERM=linux && run this && then this'"]
      @checks.should == ["su - someone -c 'it worked'"]
    end

    it 'should check a file' do
      run 'command', :check => check_file('somefile'), :as => 'auser'
      @checks.should == ["su - auser -c 'test -s somefile && echo CHECK PASSED || echo CHECK FAILED'"]
    end
  end

  describe 'gem' do
    it 'should add a command to install a gem' do
      gem 'package'
      @added.should == ['export TERM=linux && gem install package']
    end

    it 'should add a command to install a gem with a specified version' do
      gem 'package', :version => '1'
      @added.should == ["export TERM=linux && gem install package -v '1'"]
    end
  end

  describe 'gem_update' do
    it 'should add a command to update gems' do
      gem_update 'gem'
      @added.should == ['export TERM=linux && gem update gem']
    end
  end

  describe 'extract' do
    it 'should add commands to download, extract and remove an archive' do
      extract 'http://url/package'
      @added.should == ['cd /tmp && wget http://url/package && tar -zxf package && rm package && cd -']
    end

    it 'should add commands to download, extract and remove a zip archive' do
      extract 'http://url/package.zip'
      @added.should == ['cd /tmp && wget http://url/package.zip && unzip -qq package.zip && rm package.zip && cd -']
    end
  end

  describe 'git_clone' do
    it 'should add a command to clone a git repository' do
      git_clone 'http://git_url.git'
      @added.should == ['git clone -q http://git_url.git ']
    end

    it 'should add a command to clone a git repository to a specified folder' do
      git_clone 'http://git_url.git', :to => 'dir'
      @added.should == ['git clone -q http://git_url.git dir']
    end
  end
end

