require 'spec_helper'

describe 'Configuration' do
  include Machines::Core
  include Machines::FileOperations
  include Machines::Helpers
  include Machines::Configuration

  describe 'machine' do
    it 'should set environment, apps and role when it matches the configuration specified' do
      pending
      machine 'machine', :test, {:apps => ['app', 'another'], :roles => [:role]}
      @environment.should == :test
      @apps.should == ['app', 'another']
      @roles.should == [:role]
    end

    it 'should set environment when it matches specified configuration but no apps or role specified' do
      pending
      @config = 'config'
      machine 'config', :test
      @environment.should == :test
    end

    it 'should not set anything when it does not match specified configuration' do
      pending
      machine 'config', :test, {:apps => ['app', 'another'], :role => 'role'}
      @environment.should be_nil
      @apps.should be_nil
      @role.should be_nil
    end
  end

  describe 'password' do
    it 'should add a password to existing passwords' do
      @passwords = {'app' => 'password'}
      password 'another', 'anotherpass'
      @passwords.should == {'app' => 'password', 'another' => 'anotherpass'}
    end

    it 'should add a password to empty passwords' do
      @passwords = {}
      password 'app', 'newpass'
      @passwords.should == {'app' => 'newpass'}
    end
  end

  describe 'append' do
    it 'should echo a string to a file' do
      append 'some string', :to => 'a_file'
      AppConf.commands.map(&:command).should == ["export TERM=linux && echo 'some string' >> a_file"]
    end
  end

  describe 'export' do
    it 'should fail when not given a file' do
      lambda{export :key => :value}.should raise_error(ArgumentError)
    end

    it 'should export a key/value to a file' do
      export :key => :value, :to => 'to_file'
      AppConf.commands.map(&:command).should == ["export TERM=linux && echo 'export key=value' >> to_file"]
      AppConf.commands.map(&:check).should == ["grep 'export key=value' to_file #{echo_result}"]
    end
  end

  describe 'add_user' do
    it do
      add_user 'login'
      AppConf.commands.map(&:command).should == ['export TERM=linux && useradd -s /bin/bash -d /home/login -m login']
      AppConf.commands.map(&:check).should == ["test -d /home/login #{echo_result}"]
    end

    it do
      add_user 'a_user', :password => 'password', :admin => true
      AppConf.commands.map(&:command)[0].should match /useradd -s \/bin\/bash -d \/home\/a_user -m -p .* -G admin a_user/
      AppConf.commands.map(&:check).should == ["test -d /home/a_user #{echo_result}"]
    end
  end

  describe 'del_user' do
    it 'should call deluser with remove-all-files option' do
      del_user 'login'
      AppConf.commands.map(&:command).should == ['export TERM=linux && deluser login --remove-home -q']
      AppConf.commands.map(&:check).should == ["test ! -s /home/login #{echo_result}"]
    end
  end
end

