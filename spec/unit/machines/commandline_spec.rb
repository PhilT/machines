require 'spec_helper'

describe 'CommandLine' do
  include Core
  include Commandline

  describe 'start' do
    it 'calls specified command' do
      %w(htpasswd check dryrun build).each do |command|
        should_receive command
        start command, nil
        AppConf.action.should == command
      end
    end

    it 'calls generate with directory' do
      should_receive(:generate).with('dir')
      start 'new', 'dir'
    end

    it 'calls generate without directory' do
      should_receive(:generate).with(no_args)
      start 'new', nil
    end

    it 'calls help when no matching command' do
      stub!('anything').and_raise NoMethodError
      should_receive(:help)
      start('anything', nil)
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

  describe 'htpasswd' do
    it 'htpasswd is generated and saved' do
      AppConf.webserver = 'server'
      $input.answers = %w(user pass pass)
      htpasswd
      File.read('/tmp/server/conf/htpasswd').should =~ /user:.{13}/
    end
  end

  describe 'generate' do
    it 'copies the template' do
      FileUtils.should_receive(:cp_r).with("#{AppConf.application_dir}/template", AppConf.project_dir)
      generate nil
    end

    it 'copies the template within dir' do
      FileUtils.should_receive(:cp_r).with("#{AppConf.application_dir}/template", AppConf.project_dir + '/dir')
      should_receive(:say).with('Project created at /tmp/dir')
      generate 'dir'
    end

    it 'displays message and terminates when directory exists' do
      FileUtils.mkdir_p('/tmp/dir')
      should_receive(:say).with('Directory already exists')
      generate 'dir'
    end
  end

  describe 'packages' do
    it 'displays a list of default and project packages' do
      FileUtils.mkdir_p File.join(AppConf.application_dir, 'packages')
      FileUtils.mkdir_p File.join(AppConf.project_dir, 'packages')
      FileUtils.touch File.join(AppConf.application_dir, 'packages', 'base.rb')
      FileUtils.touch File.join(AppConf.project_dir, 'packages', 'apps.rb')
      packages
      $output.should == 'Default packages
 * base
Project packages
 * apps
'
    end
  end

  describe 'override' do
    before(:each) do
      FileUtils.mkdir_p File.join(AppConf.application_dir, 'packages')
      FileUtils.mkdir_p File.join(AppConf.project_dir, 'packages')
      FileUtils.touch File.join(AppConf.application_dir, 'packages', 'base.rb')
    end

    it 'copies package to project directory' do
      override 'base'
      File.should exist File.join(AppConf.project_dir, 'packages', 'base.rb')
    end

    context 'when copying over existing package' do
      before(:each) do
        FileUtils.touch File.join(AppConf.project_dir, 'packages', 'base.rb')
      end

      it 'terminates when user answer no' do
        $input.answers = %w(n)
        override 'base'
        $output.should == 'Package already exists. Overwrite? (y/n)
Aborted.
'
      end

      it 'overwrites project package with default package' do
        $input.answers = %w(y)
        override 'base'
        $output.should == 'Package already exists. Overwrite? (y/n)
Package copied to packages/base.rb
'
      end
    end
  end
end

