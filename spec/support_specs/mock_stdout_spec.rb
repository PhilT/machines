require 'spec_helper'

describe MockStdout do
  it 'handles console output' do
    say('something')
    $output.buffer.must_equal "something\n"
  end

  it 'cleans extra trailing carriage returns' do
    say("something\n\n\nand something else\n\n")
    $output.buffer.must_equal "something\nand something else\n"
  end
end

