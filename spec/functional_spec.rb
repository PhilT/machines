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
    @log.should == [")    sed -i 's/ubuntu/selected/' /etc/{hosts,hostname}", ')    etc/hosts /etc/hosts']
    @commands.should == [['', "sed -i 's/ubuntu/selected/' /etc/{hosts,hostname}", "grep 'selected' /etc/{hosts,hostname} && echo CHECK PASSED || echo CHECK FAILED"], ['', ["etc/hosts", "/etc/hosts"], 'test -f /etc/hosts && echo CHECK PASSED || echo CHECK FAILED']]
  end

  it 'should install a minimal script' do
    pending
  end
end

