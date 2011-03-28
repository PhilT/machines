require 'spec_helper'

describe 'HighLine' do
  before(:each) do
    @input = MockStdIn.new
    @output = MockStdOut.new
    $terminal = HighLine.new(@input, @output)
  end

  it 'handles console output' do
    say('something')
    @output.buffer.should == "something\n"
  end

  it 'handles console input' do
    @input.buffer = 'test'
    ask('something').should == 'test'
  end
end

