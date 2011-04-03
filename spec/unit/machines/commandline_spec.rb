require 'spec_helper'

describe 'CommandLine' do
  include Machines::Commandline

  before(:each) do
    stub!(:say, :ask)
  end

  describe 'start' do
    it 'calls specified command' do
      %w(htpasswd generate check dryrun build).each do |command|
        should_receive command
        start command
        AppConf.action.should == command
      end
    end

    it 'calls help when no matching command' do
      should_receive(:help)
      start('anything')
    end
  end

  describe 'help' do
    it 'displays the help' do
      should_receive(:say).with /machines COMMAND/
      help
    end
  end

  describe 'enter_and_confirm_password' do
    it 'does not echo output' do
      mock_question = mock HighLine::Question
      mock_question.should_receive(:echo=).with(false).twice
      stub!(:ask).and_yield mock_question
      enter_and_confirm_password
    end

    it 'asks for a password and confirmation' do
      should_receive(:ask).with('Enter a new password: ').once.and_return 'pass'
      should_receive(:ask).with('Confirm the password: ').once.and_return 'pass'
      enter_and_confirm_password.should == 'pass'
    end

    it 'repeats until password and confirmation match' do
      should_receive(:ask).with('Enter a new password: ').twice.and_return 'pass'
      should_receive(:ask).with('Confirm the password: ').twice.and_return 'pas', 'pass'
      should_receive(:say).with('Passwords do not match, please re-enter')
      enter_and_confirm_password.should == 'pass'
    end
  end

  describe 'generate' do
    it 'copies the template' do
      FileUtils.should_receive(:cp_r).with("#{AppConf.application_dir}/template", AppConf.project_dir)
      generate
    end
  end
end

