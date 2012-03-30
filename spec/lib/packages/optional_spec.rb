require 'spec_helper'

describe 'packages/optional' do
  before(:each) do
    load_package('optional')
    FileUtils.mkdir_p '~/workspace'
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   workspace - Copies everything from local workspace folder to new machine",
      'UPLOAD ~/workspace to workspace',
      'RUN    mkdir -p Documents Downloads Music Pictures Videos'
    ]
  end
end

