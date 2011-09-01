require 'spec_helper'

describe 'packages/timezone' do
  before(:each) do
    load_package('timezone')
    AppConf.timezone = 'GB'
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   timezone - Set timezone from config.yml",
      "SUDO   ln -sf /etc/localtime /usr/share/zoneinfo/GB",
      "SUDO   sed -i \"s/UTC=yes/UTC=no/\" /etc/default/rcS",
      'SUDO   echo "ntpdate -s ntp.ubuntu.com pool.ntp.org" > /etc/cron.daily/ntpdate',
      "SUDO   chmod 755 /etc/cron.daily/ntpdate"
    ]
  end
end

