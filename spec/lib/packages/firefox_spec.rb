require 'spec_helper'

describe 'packages/firefox' do
  before(:each) do
    load_package('firefox')
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   firefox - install firefox",
      "SUDO   apt-get -q -y install firefox"
    ]
  end
end

