require 'spec/spec_helper'

describe 'Functional Specs' do
  before(:each) do
    stub!(:print)
  end

  module Machines
    class Base
      attr_reader :log, :commands
      def load_machinesfile name
        @log = []
        @config_name = name
        machine 'selected', :development
        upload 'etc/hosts', '/etc/hosts'
      end

      def log_to file, message
        @log << message
      end
    end
  end

  it 'should test a minimal script' do

    machines = Machines::Base.new :password => 'password'
    machines.test 'selected'

    machines.log.should == [')    etc/hosts to /etc/hosts']
    machines.commands.should == [['', ["etc/hosts", "/etc/hosts"], 'test -s /etc/hosts && echo CHECK PASSED || echo CHECK FAILED']]
  end

  it 'should install a minimal script' do
    pending
  end
end

