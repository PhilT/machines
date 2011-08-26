require 'spec_helper'

describe MockStdout do
  it 'handles console output' do
    say('something')
    $output.should == "something\n"
  end

  it 'cleans directories' do
    say("something with #{AppConf.project_dir}/in")
    $output.should == "something with in\n"
  end

  it 'cleans extra trailing carriage returns' do
    say("something\n\n\nand something else\n\n")
    $output.should == "something\nand something else\n"
  end
end

