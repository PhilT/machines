require 'spec_helper'

describe 'Configuration' do
  describe 'add_user' do
    it do
      subject = add_user 'login'
      subject.command.should == 'useradd -s /bin/bash -d /home/login -m login'
      subject.check.should == "test -d /home/login #{echo_result}"
    end

    it do
      subject = add_user 'a_user', :password => 'password', :admin => true
      subject.command.should match /useradd -s \/bin\/bash -d \/home\/a_user -m -p .* -G admin a_user/
      subject.check.should == "test -d /home/a_user #{echo_result}"
    end
  end

  describe 'configure' do
    before(:each) do
      @options = {:string => 'str', :number => 123, :t => true, :f => false, :float => 1.1, :array => ['item 1', 'item 2']}
    end

    it 'supports different types' do
      actual = configure @options
      actual.map(&:command).should == [
        'gconftool-2 --set "string" --type string "str"',
        'gconftool-2 --set "number" --type int 123',
        'gconftool-2 --set "t" --type bool true',
        'gconftool-2 --set "f" --type bool false',
        'gconftool-2 --set "float" --type float 1.1',
        'gconftool-2 --set "array" --type list --list-type=string ["item 1","item 2"]'
      ]
    end

    it { lambda{ configure(:invalid_type => Object.new) }.should raise_error }
  end

  describe 'del_user' do
    it 'calls deluser with remove-all-files option' do
      subject = del_user 'login'
      subject.command.should == 'deluser login --remove-home -q'
      subject.check.should == "test ! -s /home/login #{echo_result}"
    end
  end
end

