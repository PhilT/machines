require 'spec_helper'

describe 'packages/dependencies' do
  before(:each) do
    load_package('dependencies')
    $conf.hostname = 'hostname'
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   dependencies - Dependencies required for various commands to run",
      "SUDO   apt-get -q -y update > /tmp/apt-update.log",
      "SUDO   apt-get -q -y install debconf-utils",
      "SUDO   apt-get -q -y install python-software-properties",
      "SUDO   apt-get -q -y install gconf2",
    ]
  end
end

