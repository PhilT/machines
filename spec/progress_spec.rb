require 'spec_helper'

describe Progress do
  before(:each) do
    @progress = Progress.new(10)
    @progress.advance
  end

  it 'should show a line with information' do
    @progress.show(1, 'a command', 'Running').should == "\rStep 1 of 10    ( 10%), line   1: Running a command                                                     "
  end

  it 'should show a line with information and progress' do
    @progress.advance
    @progress.show(2, 'a command', 'Running').should == "\rStep 2 of 10    ( 20%), line   2: Running a command                                                     "
  end

  it 'should truncate multi-line commands' do
    @progress.show(1, "multi\nline\ncommand", 'Running').should == "\rStep 1 of 10    ( 10%), line   1: Running multi...                                                      "
  end

  it 'should truncate long commands' do
    @progress.truncate_at 20
    @progress.show(1, "this is a really long command line", 'Running').should == "\rStep 1 of 10    ( 10%), line   1: Running this is a really lon..."
  end

  it 'should not show two sets of ... when truncating because of both multi-line and long line' do
    @progress.truncate_at 20
    @progress.show(1, "this is multi line\ncommand", '').should == "\rStep 1 of 10    ( 10%), line   1:  this is multi line...        "
  end

  it 'should handle uploads' do
    @progress.show(1, ['from here', 'here'], 'Upload').should == "\rStep 1 of 10    ( 10%), line   1: Upload from here to here                                              "
  end
end

