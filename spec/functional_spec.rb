require 'spec/spec_helper'


describe 'Functional Specs' do
  before(:each) do
    configure 'selected', nil, nil, nil, nil, nil
    @log = []
  end

  def log message
    @log << message
  end

  it 'should build a minimal script' do
    machine 'selected', :development
    upload 'etc/hosts', '/etc/hosts'

    start 'test'
    @log.should == ['upload          etc/hosts /etc/hosts']
    @commands.should == [["upload", ["etc/hosts", "/etc/hosts"]]]
  end
end

