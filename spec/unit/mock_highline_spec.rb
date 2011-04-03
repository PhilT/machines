require 'spec_helper'

describe 'HighLine' do
  it 'handles console output' do
    say('something')
    $output.should == "something\n"
  end

  it 'handles multiple console inputs' do
    $input.answers = ["test", "this"]
    ask('something? ').should == 'test'
    ask('something else? ').should == 'this'
    say('finally say something.')
    $output.should == <<-THIS
something?
something else?
finally say something.
THIS
  end

  it 'handles character input with no echo' do
    $input.answers = ['first', 'second']
    ask('hidden 1? ') { |question| question.echo = false }.should == 'first'
    ask('hidden 2? ') { |question| question.echo = false }.should == 'second'
    $output.should == "hidden 1?\nhidden 2?\n"
  end
end

