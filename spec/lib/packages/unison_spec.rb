require 'spec_helper'

describe 'packages/unison' do
  before(:each) do
    $conf.machine = AppConf.new
    $conf.machine.user = 'username'
    eval_package
  end

  it 'adds the following commands' do
    $conf.commands.map(&:info).must_equal [
      "TASK   unison - Install and configure Unison (users/username/.unison/default.prf)",
      "SUDO   apt-get -q -y install unison",
      "RUN    echo '30 18 * * * /usr/bin/unison' | crontab"
    ]
  end
end

