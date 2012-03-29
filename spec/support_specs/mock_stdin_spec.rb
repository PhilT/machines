require 'spec_helper'

describe MockStdin do
  it 'handles multiple console inputs' do
    $input.answers = ["test", "this"]
    ask('something? ').must_equal 'test'
    ask('something else? ').must_equal 'this'
    say('finally say something.')
    $output.buffer.must_equal <<-THIS
something?
something else?
finally say something.
THIS
  end

  it 'handles character input with no echo' do
    $input.answers = ['first', 'second']
    ask('hidden 1? ') { |question| question.echo = false }.must_equal 'first'
    ask('hidden 2? ') { |question| question.echo = false }.must_equal 'second'
    $output.buffer.must_equal "hidden 1?\nhidden 2?\n"
  end
end

