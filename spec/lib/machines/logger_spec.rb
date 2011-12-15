require 'spec_helper'

describe 'Helpers' do
  before(:each) do
    AppConf.user = 'www'
    AppConf.commands = [1,2,3]
  end

  context 'logging to screen' do
    it 'logs first line only' do
      Command.console.log %(something with "some text\nsome more\nand "lets quote" this one" > and some output)
      %(something with "some text..." > and some output\n).should be_displayed
    end

    it 'truncates lines longer than screen width' do
      $terminal.stub(:output_cols).and_return 10
      Command.console.log "A line that's longer than the screen width", :newline => false
      "A line...\r".should be_displayed
    end
  end

  context 'logging to file' do
    it 'logs all lines' do
      Command.file.log %(something with "some text\nsome more\nand "lets quote" this one" > and some output)
      %(something with "some text\nsome more\nand "lets quote" this one" > and some output\n).should be_logged
    end
  end

  describe 'log' do
    it 'does not error when no message' do
      Command.file.log nil
      "(no message)\n".should be_logged
    end

    it 'returns to the beginning of the line when no newline' do
      Command.console.log 'message', :newline => false
      "message\r".should be_displayed
    end

    it 'sends the command and line number' do
      Command.file.log 'command'
      "command\n".should be_logged
    end

    it 'displays message in specified color' do
      Command.file.log 'command', :color => :yellow
      "command\n".should be_logged in_yellow
    end

    it 'does not show passwords' do
      AppConf.passwords = ['a_password', 'another password']
      Command.file.log 'something with a_password and another password in'
      "something with ***** and ***** in\n".should be_logged
    end

    it 'displays newline when empty message' do
      Command.file.log ''
      "\n".should be_logged
    end

    it 'flushes the file' do
      mock_file = mock File
      subject = Machines::Logger.new(mock_file)
      mock_file.should_receive(:flush)
      subject.flush
    end
  end
end

