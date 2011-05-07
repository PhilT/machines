require 'spec_helper'

describe 'Machines' do

  subject {Machines::Base.new}

  before(:each) do
    File.stub(:read).and_return ''
    AppConf.ec2 = AppConf.new unless AppConf.ec2
    AppConf.ec2.use = nil
  end

  describe 'build' do
    before(:each) do
      AppConf.target_address = 'target'
      AppConf.user.name = 'username'
      AppConf.user.pass = 'userpass'
    end

    it 'raises LoadError with custom message when no Machinesfile' do
      File.should_receive(:read).with("#{AppConf.project_dir}/Machinesfile").and_raise LoadError.new('Machinesfile not found')

      begin
        subject.build
      rescue LoadError => e
        e.message.should == 'Machinesfile does not exist. Use `machines generate` to create a template.'
      end
    end

    it 'raises normal LoadError on other files' do
      File.should_receive(:read).with("#{AppConf.project_dir}/Machinesfile").and_raise LoadError

      begin
        subject.build
      rescue LoadError => e
        e.message.should == 'LoadError'
      end
    end

    it 'starts an SCP session using password authentication' do
      Net::SCP.should_receive(:start).with('target', 'username', :password => 'userpass')
      subject.build
    end

    it 'starts an SCP session using key based authentication' do
      AppConf.ec2.use = true
      AppConf.ec2.private_key_file = 'private_key_file'
      Net::SCP.should_receive(:start).with('target', 'ubuntu', :keys => ['private_key_file'])

      subject.build
    end

    it 'runs each command' do
      mock_command = mock Command
      mock_scp = mock Net::SCP, :session => nil
      AppConf.commands = [mock_command]

      Net::SCP.should_receive(:start).with('target', 'username', :password => 'userpass').and_yield(mock_scp)
      Command.should_receive(:scp=).with(mock_scp)
      mock_command.should_receive(:run)

      subject.build
    end
  end
end

