require 'spec_helper'

describe Machines::Logger do
  before(:each) do
    $conf.machine = AppConf.new
    $conf.machine.user = 'www'
    $conf.commands = [1,2,3]
  end

  describe 'logging to screen' do
    it 'logs first line only' do
      Machines::Command.console.log %(something with "some text\nsome more\nand "lets quote" this one" > and some output)
      $console.next.must_equal %(something with "some text..." > and some output\n)
    end

    it 'truncates lines longer than screen width' do
      $terminal.stubs(:output_cols).returns 10
      Machines::Command.console.log "A line that's longer than the screen width", :newline => false
      $console.next.must_equal "A line...\r"
    end
  end

  describe 'logging to file' do
    it 'logs all lines' do
      Machines::Command.file.log %(something with "some text\nsome more\nand "lets quote" this one" > and some output)
      $file.next.must_equal %(something with "some text\nsome more\nand "lets quote" this one" > and some output\n)
    end
  end

  describe 'log' do
    it 'does not error when no message' do
      Machines::Command.file.log nil
      $file.next.must_equal "(no message)\n"
    end

    it 'returns to the beginning of the line when no newline' do
      Machines::Command.console.log 'message', :newline => false
      $console.next.must_equal "message\r"
    end

    it 'sends the command and line number' do
      Machines::Command.file.log 'command'
      $file.next.must_equal "command\n"
    end

    it 'displays message in specified color' do
      Machines::Command.file.log 'command', :color => :yellow
      $file.next.must_equal colored("command\n", :yellow)
    end

    it 'does not show passwords' do
      $passwords.to_filter = ['a_password', 'another password']
      Machines::Command.file.log 'something with a_password and another password in'
      $file.next.must_equal "something with ***** and ***** in\n"
    end

    it 'displays newline when empty message' do
      Machines::Command.file.log ''
      $file.next.must_equal "\n"
    end

    it 'flushes the file' do
      mock_file = mock 'File'
      subject = Machines::Logger.new(mock_file)
      mock_file.expects(:flush)
      subject.flush
    end
  end
end

