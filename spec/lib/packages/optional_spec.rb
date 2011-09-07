require 'spec_helper'

describe 'packages/optional' do
  before(:each) do
    load_package('optional')
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   workspace - Copies everything from local workspace folder to new machine",
      'UPLOAD ~/workspace to ~/workspace'
    ]
  end
end

