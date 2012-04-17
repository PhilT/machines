require 'spec_helper'

describe 'packages/unison' do
  before(:each) do
    load_package('unison')
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   unison - Install unison two way file sync and set it to run hourly. Config in users/user/.unison/default.prf",
      "SUDO   apt-get -q -y install unison",
      "RUN    echo '30 18 * * * /usr/bin/unison' | crontab"
    ]
  end
end

