require 'spec_helper'

describe 'Questions' do
  describe 'choose_machine' do
    before(:each) do
      File.stub(:read).with("Machinesfile").and_return <<-MACHINESFILE
machine 'Desktop', :development, :roles => [:app, :db], :apps => ['main', 'wiki']
machine 'Staging', :staging, :roles => [:app, :db], :apps => ['main', 'wiki']
machine 'Production', :production, :roles => :app, :apps => ['main', 'wiki']
MACHINESFILE
      @mock_menu = mock HighLine::Menu, :prompt= => nil
    end

    it 'loads options from Machinesfile' do
      should_receive(:choose).with('Desktop', 'Staging', 'Production').and_yield @mock_menu
      choose_machine
    end

    it 'prompts user to select machine' do
      @mock_menu.should_receive(:prompt=).with('Select machine to build: ')
      should_receive(:choose).and_yield @mock_menu
      choose_machine
    end

    it 'sets the choice' do
      should_receive(:choose).and_return 'Staging'
      choose_machine.should == 'Staging'
    end
  end

  describe 'start_ec2_instance' do
    it 'returns true' do
      should_receive(:agree).with('Would you like to start a new EC2 instance (y/n)? ').and_return true
      start_ec2_instance?.should be_true
    end

    it 'returns false' do
      should_receive(:agree).with('Would you like to start a new EC2 instance (y/n)? ').and_return false
      start_ec2_instance?.should be_false
    end
  end

  describe 'target_address' do
    it 'accepts IP or DNS address of target machine' do
      should_receive(:ask).with('Enter the IP or DNS address of the target machine (EC2, VM or LAN address): ').and_return 'target ip'
      enter_target_address('machine').should == 'target ip'
    end
  end

  describe 'choose_user' do
    before(:each) do
      AppConf.users = ['a_user', 'another']
      @mock_menu = mock(HighLine::Menu, :prompt= => nil)
    end

    it 'loads options' do
      should_receive(:choose).with('a_user', 'another').and_yield @mock_menu
      choose_user
    end

    it 'prompt displayed to select a user' do
      @mock_menu.should_receive(:prompt=).with('Select a user: ')
      should_receive(:choose).and_yield @mock_menu
      choose_user
    end

    it 'sets the choice' do
      should_receive(:choose).and_return('a_user')
      choose_user.should == 'a_user'
    end
  end

  describe 'enter_password' do
    before(:each) do
      stub!(:ask).and_return 'password'
    end

    it 'does not echo output' do
      mock_question = mock HighLine::Question
      mock_question.should_receive(:echo=).with(false).twice
      stub!(:ask).and_yield(mock_question).and_return 'password'
      enter_password 'type'
    end

    it 'prompts for a password' do
      should_receive(:ask).with('Enter type password: ').once.and_return 'password'
      enter_password('type')
    end

    it 'returns password' do
      enter_password('type').should == 'password'
    end

    it 'adds to password list' do
      enter_password('type')
      AppConf.passwords.should == ['password']
    end

    it 'does not add password less than 5 characters to password list' do
      stub!(:ask).and_return 'pass'
      enter_password('type')
      AppConf.passwords.should == []
    end

    it 'repeats until password and confirmation match' do
      should_receive(:ask).with('Enter type password: ').twice.and_return 'password'
      should_receive(:ask).with('Confirm the password: ').twice.and_return 'pas', 'password'
      should_receive(:say).with('Passwords do not match, please re-enter')
      enter_password('type').should == 'password'
    end

    it 'only asks once when confirm set to false' do
      should_receive(:ask).with('Enter type password: ').once.and_return 'password'
      should_not_receive(:ask).with('Confirm the password: ')
      enter_password('type', false)
    end

    it 'password still added to list when not confirming' do
      enter_password('type', false)
      AppConf.passwords.should == ['password']
    end

    it 'password still returned when not confirming' do
      enter_password('type', false).should == 'password'
    end

    it 'do not add to passwords list if not available' do
      AppConf.passwords = nil
      enter_password('type')
      AppConf.passwords.should be_nil
    end
  end

  describe 'enter_hostname' do
    it 'accepts hostname' do
      should_receive(:ask).with('Enter a hostname (can be fully qualified domain): ').and_return 'host'
      enter_hostname.should == 'host'
    end
  end
end

