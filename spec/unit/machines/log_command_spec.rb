require 'spec_helper'

describe LogCommand do
  subject {LogCommand.new :name, 'description'}

  it 'logs the name and description' do
    AppConf.commands = [subject]
    subject.run
    "\n".should be_displayed
    "100% TASK   name - description\n".should be_displayed as_info

    "\n".should be_logged
    "TASK   name - description\n".should be_logged as_info
  end
end

