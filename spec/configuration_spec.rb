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

  describe 'add_user' do
    it 'should call useradd' do
      add_user 'login'
      @added.should == ['useradd login']
    end
  end

  describe 'del_user' do
    it 'should call deluser with remove-all-files option' do
      del_user 'login'
      @added.should == ['deluser login --remove-all-files']
    end
  end
end

