require 'spec/spec_helper'

describe 'Configuration' do
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
    end
  end

  describe 'set_machine_name_and_hosts' do
    it 'should upload /etc/hosts and set hostname' do
      stub!(:development?).and_return(true)
      File.stub!(:exist?).and_return(true)
      @machinename = 'machine'
      set_machine_name_and_hosts
      @added.should == [["etc/hosts", "/etc/hosts"], "sed -i 's/ubuntu/machine/' /etc/{hosts,hostname}", 'hostname machine']
    end
  end

  describe 'add_user' do
    it do
      add_user 'login'
      @added.should == ['useradd -d /home/login -m login']
    end

    it do
      add_user 'a_user', :password => 'password', :admin => true
      @added.should == ['useradd -d /home/a_user -m -p password -G admin a_user']
    end
  end

  describe 'del_user' do
    it 'should call deluser with remove-all-files option' do
      del_user 'login'
      @added.should == ['deluser login --remove-all-files']
    end
  end
end

