require 'spec/spec_helper'

describe 'Configuration' do
  def add to_add
    @added << to_add
  end

  before(:each) do
    @added = []
  end

  describe 'append' do
    it 'should echo a string to a file' do
      append 'some string', :to => 'a_file'
      @added.should == ["echo 'some string' >> a_file"]
    end
  end

  describe 'export' do
    it 'should export a key/value pair' do
      export :key => :value, :key => :value
      @added.should == ["export key=value"]
    end

    it 'should export a key/value pair and write to a file' do
      export :key => :value, :key => :value, :to => 'to_file'
      @added.should == ["export key=value && echo 'export key=value' >> to_file"]
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

