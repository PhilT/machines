require 'spec/spec_helper'

describe 'Functional Specs' do
  before(:each) do
    configure ['selected', nil, 'password']
    @log = []
    stub!(:print)
  end

  def log_to file, message
    @log << message
  end

  def add command, check
    real_add command, check
  end

  it 'should test a minimal script' do
    machine 'selected', :development
    upload 'etc/hosts', '/etc/hosts'

    start 'test'
    @log.should == [')    etc/hosts to /etc/hosts']
    @commands.should == [['', ["etc/hosts", "/etc/hosts"], 'test -f /etc/hosts && echo CHECK PASSED || echo CHECK FAILED']]
  end

  it 'should install a minimal script' do
    pending
  end
end

