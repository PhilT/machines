require 'spec/spec_helper'

describe 'Installation' do
  def add to_add
    @added << to_add
  end

  before(:each) do
    @added = []
  end

  describe 'update' do
    it 'should add a command to upgrade apt' do
      update
      @added.should == ['apt-get update && apt-get upgrade']
    end
  end

  describe 'install' do
    it 'should add a command to install from an install script' do
      should_receive(:required_options).with({:in => '~/installer'}, [:in])
      install :sh, :in => '~/installer'
      @added.should == ['cd ~/installer && ./install.sh -y']
    end

    it 'should add a command to install apt packages' do
      install %w(package1 package2)
      @added.should == ['apt-get install -q -y package1 package2']
    end

    it 'should add commands to download, install and remove a package ' do
      install "http://some.url/package_name.deb"
      @added.should == ['cd /tmp && wget http://some.url/package_name.deb && dpkg -i package_name.deb && rm package_name.deb && cd -']
    end
  end

  describe 'gem' do
    it 'should add a command to install a gem' do
      gem 'package'
      @added.should == ['gem install package']
    end

    it 'should add a command to install a gem with a specified version' do
      gem 'package', :version => '1'
      @added.should == ["gem install package -v '1'"]
    end
  end

  describe 'gem_update' do
    it 'should add a command to update gems' do
      gem_update 'gem'
      @added.should == ['gem update gem']
    end
  end

  describe 'extract' do
    it 'should add commands to download, extract and remove an archive' do
      extract 'http://url/package'
      @added.should == ['cd /tmp && wget http://url/package && tar -zxvf package && rm package && cd -']
    end

    it 'should add commands to download, extract and remove a zip archive' do
      extract 'http://url/package.zip'
      @added.should == ['cd /tmp && wget http://url/package.zip && unzip package.zip && rm package.zip && cd -']
    end
  end

  describe 'git_clone' do
    it 'should add a command to clone a git repository' do
      git_clone 'http://git_url.git'
      @added.should == ['git clone http://git_url.git ']
    end

    it 'should add a command to clone a git repository to a specified folder' do
      git_clone 'http://git_url.git', :to => 'dir'
      @added.should == ['git clone http://git_url.git dir']
    end
  end

  describe 'install_nginx' do
    it 'should add commands to download and extract nginx and install passenger' do
      install_nginx 'http://url_to_nginx.tar.gz'
      @added.should == ['cd /tmp && wget http://url_to_nginx.tar.gz && tar -zxvf url_to_nginx.tar.gz && rm url_to_nginx.tar.gz && cd -', 'cd /tmp && passenger-install-nginx-module --auto --nginx-source-dir=/tmp/url_to_nginx && rm -rf url_to_nginx && cd -']
    end

    it 'should add commands to download and extract nginx and install passenger with ssl module' do
      install_nginx 'http://url_to_nginx.tar.gz', :with => :ssl
      @added.should == ['cd /tmp && wget http://url_to_nginx.tar.gz && tar -zxvf url_to_nginx.tar.gz && rm url_to_nginx.tar.gz && cd -', 'cd /tmp && passenger-install-nginx-module --auto --nginx-source-dir=/tmp/url_to_nginx --extra-configure-flags=--with-http_ssl_module && rm -rf url_to_nginx && cd -']
    end
  end
end

