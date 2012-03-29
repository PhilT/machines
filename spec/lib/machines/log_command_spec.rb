require 'spec_helper'

describe Machines::LogCommand do
  subject {Machines::LogCommand.new :name, 'description'}

  it 'logs the name and description' do
    AppConf.commands = [subject]
    subject.run
    $console.next.must_equal "\n"
    $console.next.must_equal colored("     TASK   name - description\n", :info)

    $file.next.must_equal "\n"
    $file.next.must_equal colored("TASK   name - description\n", :info)
  end
end

