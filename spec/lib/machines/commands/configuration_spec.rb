require 'spec_helper'

describe Commands::Configuration do

  describe 'add_user' do
    it do
      command = add_user 'login'
      command.command.must_equal 'useradd -s /bin/bash -d /home/login -m login'
      command.check.must_equal "test -d /home/login #{echo_result}"
    end

    it do
      command = add_user 'a_user', :password => 'password', :admin => true
      command.command.must_match /useradd -s \/bin\/bash -d \/home\/a_user -m -p .* -G admin a_user/
      command.check.must_equal "test -d /home/a_user #{echo_result}"
    end
  end

  describe 'add' do
    it 'add an existing user to a group' do
      stubs(:required_options)
      command = add :user => 'phil', :to => 'group'
      command.command.must_equal 'usermod -a -G group phil'
    end
  end

  describe 'configure' do
    before(:each) do
      @options = {:string => 'str', :number => 123, :t => true, :f => false, :float => 1.1, :array => ['item 1', 'item 2']}
    end

    it 'supports different types' do
      commands = configure @options
      commands.map(&:command).must_equal [
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
      command.first.check.must_equal 'gconftool-2 --get "key" | grep "value" ' + echo_result
    end

    it { lambda{ configure(:invalid_type => Object.new) }.must_raise RuntimeError }
  end

  describe 'del_user' do
    it 'calls deluser with remove-all-files option' do
      subject = del_user 'login'
      subject.command.must_equal 'deluser login --remove-home -q'
      subject.check.must_equal "test ! -s /home/login #{echo_result}"
    end
  end
end

