require 'spec_helper'

describe 'Questions' do
  include Machines::Questions

  describe 'choose_machine' do
    before(:each) do
      File.stub(:read).with("#{AppConf.project_dir}/Machinesfile").and_return <<-MACHINESFILE
machine 'Desktop', :development, :roles => [:app, :db], :apps => ['main', 'wiki']
machine 'Staging', :staging, :roles => [:app, :db], :apps => ['main', 'wiki']
machine 'Production', :production, :roles => :app, :apps => ['main', 'wiki']
MACHINESFILE
      @mock_menu = mock HighLine::Menu, :prompt => nil
    end

    it 'loads options from Machinesfile' do
      should_receive(:choose).with('Desktop', 'Staging', 'Production').and_yield @mock_menu
      choose_machine
    end

    it 'prompts user to select machine' do
      @mock_menu.should_receive(:prompt).with('Select machine to build:')
      should_receive(:choose).with('Desktop', 'Staging', 'Production').and_yield @mock_menu
      choose_machine
    end

    it 'sets the choice' do
      should_receive(:choose).with('Desktop', 'Staging', 'Production').and_return 'Staging'
      choose_machine
      AppConf.machine.should == 'Staging'
    end
  end

  describe 'start_ec2_instance' do
    it 'sets AppConf.ec2_instance to true' do
      should_receive(:agree).with('Would you like to start a new EC2 instance (y/n)?').and_return true
      start_ec2_instance?
      AppConf.ec2_instance.should be_true
    end

    it 'sets AppConf.ec2_instance to false' do
      should_receive(:agree).with('Would you like to start a new EC2 instance (y/n)?').and_return false
      start_ec2_instance?
      AppConf.ec2_instance.should be_false
    end
  end

  describe 'target_address' do
    it 'accepts IP or DNS address of target machine' do
      should_receive(:ask).with('Enter the IP or DNS address of the target machine (EC2, VM, LAN):').and_return 'target ip'
      enter_target_address
      AppConf.target_address.should == 'target ip'
    end
  end

  describe 'choose_user' do
    it 'loads options from users.yml' do
      pending
    end
  end
end

