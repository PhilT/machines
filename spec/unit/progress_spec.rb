require 'spec_helper'

describe Progress do
  before(:each) do
    @progress = Progress.new(10)
    @progress.advance
  end

  it 'should show a line with information' do
    @progress.show(1, 'a command').should match /\r  1\/10  \( 10%\), line   1: a command/
  end

  it 'should show a line with information and progress' do
    @progress.advance
    @progress.show(2, 'a command').should match /\r  2\/10  \( 20%\), line   2: a command/
  end

  it 'should truncate multi-line commands' do
    @progress.show(1, "multi\nline\ncommand").match /\r  1\/10  \( 10%\), line   1: multi.../
  end

  it 'should truncate long commands' do
    @progress.truncate_at 20
    @progress.show(1, "this is a really long command line").should match /\r  1\/10  \( 10%\), line   1: this is a really lon.../
  end

  it 'should not show two sets of ... when truncating because of both multi-line and long line' do
    @progress.truncate_at 20
    @progress.show(1, "this is multi line\ncommand").should match /\r  1\/10  \( 10%\), line   1: this is mult.../
  end

  it 'should handle uploads' do
    @progress.show(1, ['from here', 'here']).should match /\r  1\/10  \( 10%\), line   1: from here to here/
  end

  it 'should remove unimportant details from command' do
    command = "export TERM=linux && export DEBIAN_FRONTEND=noninteractive && apt-get install something"
    @progress.show(1, command).should match /\r  1\/10  \( 10%\), line   1: apt-get install something/
  end

  it 'should be the right length when truncated' do
    @progress.truncate_at 30
    @progress.show(1, 'long command').length.should == 30 + "\r".length
  end

  it 'should be the right length when not truncated' do
    @progress.truncate_at 100
    @progress.show(1, 'command').length.should == 100 + "\r".length
  end
end

