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

  it 'handles multiple console inputs' do
    @input.answers = ['test', 'this']
    ask('something').should == 'test'
    ask('something else').should == 'this'
  end

  it 'handles console character input' do
    @input.answers = ['test']
    answer = ask('something') { |question| question.echo = false }
    answer.should == 'test'
  end
end

