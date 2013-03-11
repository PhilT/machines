require 'spec_helper'

describe 'packages/git' do
  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   git - Install Git",
      'SUDO   apt-get -q -y install git-core'
    ]
  end
end

