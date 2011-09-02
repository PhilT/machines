require 'spec_helper'

describe LogCommand do
  subject {LogCommand.new :name, 'description'}

  it 'logs the name and description' do
    AppConf.commands = [subject]
    subject.run
    "\n".should be_displayed
    "     TASK   name - description\n".should be_displayed as_info

    "\n".should be_logged
    "TASK   name - description\n".should be_logged as_info
  end

  it 'equals the same LogCommand' do
    (subject == subject).should be_true
  end

  it 'equals a LogCommand with the same name and description' do
    (subject == LogCommand.new(:name, 'description')).should be_true
  end

  it 'does not equal a Command' do
    (subject == Command.new('command', 'check')).should be_false
  end

  it 'does not equal a LogCommand with a different name' do
    (subject == LogCommand.new(:different, 'description')).should be_false
  end

  it 'does not equal a LogCommand with a different description' do
    (subject == LogCommand.new(:name, 'different')).should be_false
  end
end

