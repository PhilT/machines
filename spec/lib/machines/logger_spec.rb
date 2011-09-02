require 'spec_helper'

describe 'Helpers' do
  before(:each) do
    AppConf.user.name = 'www'
    AppConf.commands = [1,2,3]
  end

  context 'logging to screen' do
    it 'logs first line only' do
      AppConf.console.log %(something with "some text\nsome more\nand "lets quote" this one" > and some output)
      %(something with "some text..." > and some output\n).should be_displayed
    end
  end

  context 'logging to file' do
    it 'logs all lines' do
      AppConf.file.log %(something with "some text\nsome more\nand "lets quote" this one" > and some output)
      %(something with "some text\nsome more\nand "lets quote" this one" > and some output\n).should be_logged
    end
  end

  describe 'log' do
    it 'does not error when no message' do
      AppConf.file.log nil
      "(no message)\n".should be_logged
    end

    it 'returns to the beginning of the line when no newline' do
      AppConf.console.log 'message', :newline => false
      "message\r".should be_displayed
    end

    it 'sends the command and line number' do
      AppConf.file.log 'command'
      "command\n".should be_logged
    end

    it 'displays message in specified color' do
      AppConf.file.log 'command', :color => :yellow
      "command\n".should be_logged in_yellow
    end

    it 'does not show passwords' do
      AppConf.passwords = ['a_password', 'another password']
      AppConf.file.log 'something with a_password and another password in'
      "something with ***** and ***** in\n".should be_logged
    end

    it 'displays newline when empty message' do
      AppConf.file.log ''
      "\n".should be_logged
    end
  end
end

