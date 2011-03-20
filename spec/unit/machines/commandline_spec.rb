require 'spec_helper'

describe 'CommandLine' do
  before(:each) do
    @machines = Machines::Base.new
    @machines.stub :say, :ask
  end

  describe 'start' do
    it 'calls specified command' do
      %w(htpasswd generate check test build).each do |command|
        @machines.should_receive command
        @machines.start command
        AppConf.action.should == command
      end
    end

    it 'calls help when no matching command' do
      @machines.should_receive(:help)
      @machines.start('anything')
    end
  end

  describe 'help' do
    it 'displays the help' do
      @machines.should_receive(:say).with /machines COMMAND/
      @machines.help
    end
  end

  describe 'enter_password' do
    it 'does not echo output' do
      mock_question = mock HighLine::Question
      mock_question.should_receive(:echo=).with(false).twice
      @machines.stub(:ask).and_yield mock_question
      @machines.enter_password
    end

    it 'asks for a password and confirmation' do
      @machines.should_receive(:ask).with('Enter a password: ').once.and_return 'pass'
      @machines.should_receive(:ask).with('Confirm the password: ').once.and_return 'pass'
      @machines.enter_password.should == 'pass'
    end

    it 'repeats until password and confirmation match' do
      @machines.should_receive(:ask).with('Enter a password: ').twice.and_return 'pass'
      @machines.should_receive(:ask).with('Confirm the password: ').twice.and_return 'pas', 'pass'
      @machines.should_receive(:say).with('Passwords do not match, please re-enter')
      @machines.enter_password.should == 'pass'
    end
  end

  describe 'htpasswd' do
    it 'asks for username' do
      File.stub(:open)
      AppConf.webserver = 'nginx'
      @machines.should_receive(:say).with 'Generate BasicAuth password and add to nginx/conf/htpasswd'
      @machines.should_receive(:ask).with('Username: ').and_return 'user'
      @machines.should_receive(:enter_password).and_return 'pass'

      FileUtils.should_receive(:mkdir_p).with('nginx/conf')
      WEBrick::Utils.stub(:random_string).with(2).and_return '12'
      @machines.should_receive(:append).with("user:#{'pass'.crypt('12')}", 'nginx/conf/htpasswd')
      @machines.should_receive(:say).with "Password encrypted and added to nginx/conf/htpasswd"
      @machines.htpasswd
    end
  end

  describe 'generate' do
    it 'copies the template' do
      FileUtils.should_receive(:cp_r).with(/lib\/machines\/..\/template\/./, ".")
      @machines.generate
    end
  end
end

