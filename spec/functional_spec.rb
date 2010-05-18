require 'spec/spec_helper'


describe 'Functional Specs' do
  before(:each) do
    configure ['selected', nil, 'password']
    @log = []
  end

  def log message
    @log << message
  end

  def add command, check
    real_add command, check
  end

  it 'should build a minimal script' do
    machine 'selected', :development
    upload 'etc/hosts', '/etc/hosts'

    start 'test'
    @log.should == ['Line :          etc/hosts /etc/hosts']
    @commands.should == [["Line :", ["etc/hosts", "/etc/hosts"], '']]
  end
end

