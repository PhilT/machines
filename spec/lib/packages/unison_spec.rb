require 'spec_helper'

describe 'packages/unison' do
  before(:each) do
    load_package('unison')
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   unison - Install unison two way file sync and set it to run hourly. Config in users/user/.unison/default.prf",
      "SUDO   apt-get -q -y install unison",
      "SUDO   ln -sf /usr/bin/unison /etc/cron.hourly/unison"
    ]
  end
end

