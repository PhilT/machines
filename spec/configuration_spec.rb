require 'spec_helper'

describe 'Configuration' do
  include Machines::FileOperations
  include Machines::Helpers
  include Machines::Configuration
  include FakeAddHelper

  describe 'machine' do
    it 'should set environment, apps and role when it matches the configuration specified' do
      @config = 'config'
      machine 'config', :test, {:apps => ['app', 'another'], :role => 'role'}
      @environment.should == :test
      @apps.should == ['app', 'another']
      @role.should == 'role'
    end

    it 'should set environment when it matches specified configuration but no apps or role specified' do
      @config = 'config'
      machine 'config', :test
      @environment.should == :test
    end

    it 'should not set anything when it does not match specified configuration' do
      machine 'config', :test, {:apps => ['app', 'another'], :role => 'role'}
      @environment.should be_nil
      @apps.should be_nil
      @role.should be_nil
    end
  end

  describe 'development?' do
    it do
      @environment = :development
      development?.should be_true
    end

    it do
      development?.should be_false
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
      @added.should == ["echo 'some string' >> a_file"]
    end
  end

  describe 'export' do
    it 'should fail when not given a file' do
      lambda{export :key => :value}.should raise_error(ArgumentError)
    end

    it 'should export a key/value to a file' do
      export :key => :value, :to => 'to_file'
      @added.should == ["echo 'export key=value' >> to_file"]
      @checks.should == ["grep 'export key=value' to_file #{pass_fail}"]
    end
  end

  describe 'set_machine_name_and_hosts' do
    it 'should upload /etc/hosts and set hostname' do
      stub!(:development?).and_return(true)
      stub!(:run)
      File.stub!(:exist?).and_return(true)
      @machinename = 'machine'
      set_machine_name_and_hosts
      @added.should == [["etc/hosts", "/etc/hosts"], "echo 'machine' > /etc/hostname"]
      @checks.should == ["test -s /etc/hosts #{pass_fail}", "grep 'machine' /etc/hostname #{pass_fail}"]
    end
  end

  describe 'add_user' do
    it do
      add_user 'login'
      @added.should == ['useradd -s /bin/bash -d /home/login -m login']
      @checks.should == ["test -d /home/login #{pass_fail}"]
    end

    it do
      add_user 'a_user', :password => 'password', :admin => true
      @added[0].should match /useradd -s \/bin\/bash -d \/home\/a_user -m -p .* -G admin a_user/
      @checks.should == ["test -d /home/a_user #{pass_fail}"]
    end
  end

  describe 'set_sudo_no_password' do
    it do
      set_sudo_no_password 'a_user'
      @added.should == ["echo 'a_user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"]
      @checks.should == ["grep 'a_user ALL=(ALL) NOPASSWD: ALL' /etc/sudoers #{pass_fail}"]
    end
  end

  describe 'unset_sudo_no_password' do
    it do
      unset_sudo_no_password 'a_user'
      @added.should == ["sed -i 's/a_user ALL=(ALL) NOPASSWD: ALL//' /etc/sudoers"]
      @checks.should == ["grep '' /etc/sudoers #{pass_fail}"]
    end
  end

  describe 'del_user' do
    it 'should call deluser with remove-all-files option' do
      del_user 'login'
      @added.should == ['deluser login --remove-home -q']
      @checks.should == ["test -s /home/login #{fail_pass}"]
    end
  end
end

