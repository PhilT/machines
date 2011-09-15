require 'spec_helper'

describe 'Configuration' do
  describe 'add_user' do
    it do
      command = add_user 'login'
      command.command.should == 'useradd -s /bin/bash -d /home/login -m login'
      command.check.should == "test -d /home/login #{echo_result}"
    end

    it do
      command = add_user 'a_user', :password => 'password', :admin => true
      command.command.should match /useradd -s \/bin\/bash -d \/home\/a_user -m -p .* -G admin a_user/
      command.check.should == "test -d /home/a_user #{echo_result}"
    end
  end

  describe 'add' do
    it 'add an existing user to a group' do
      command = add :user => 'phil', :to => 'group'
      command.command.should == 'usermod -a -G phil group'
    end
  end

  describe 'configure' do
    before(:each) do
      @options = {:string => 'str', :number => 123, :t => true, :f => false, :float => 1.1, :array => ['item 1', 'item 2']}
    end

    it 'supports different types' do
      commands = configure @options
      commands.map(&:command).should == [
        'gconftool-2 --set "string" --type string "str"',
        'gconftool-2 --set "number" --type int 123',
        'gconftool-2 --set "t" --type bool true',
        'gconftool-2 --set "f" --type bool false',
        'gconftool-2 --set "float" --type float 1.1',
        'gconftool-2 --set "array" --type list --list-type=string ["item 1","item 2"]'
      ]
    end

    it 'checks value has been set' do
      command = configure 'key' => 'value'
      command.first.check.should == 'gconftool-2 --get "key" | grep "value" ' + echo_result
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

