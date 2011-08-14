require 'spec_helper'

describe LogCommand do
  include Machines::Logger

  subject {LogCommand.new :name, 'description'}

  it 'logs the name and description' do
    subject.should_receive(:log).with("\nTASK   name - description", :color => :info)
    subject.run
  end
end

