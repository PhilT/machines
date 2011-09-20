require 'spec_helper'

describe 'packages/optional' do
  before(:each) do
    load_package('optional')
    FileUtils.mkdir_p '~/workspace'
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   workspace - Copies everything from local workspace folder to new machine",
      'UPLOAD ~/workspace to workspace',
      'RUN    mkdir -p Documents Downloads Music Pictures Videos'
    ]
  end
end

