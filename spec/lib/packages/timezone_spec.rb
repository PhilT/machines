require 'spec_helper'

describe 'packages/timezone' do
  before(:each) do
    load_package('timezone')
    AppConf.timezone = 'GB'
    @time = Time.now
    Time.stub(:now).and_return @time
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   timezone - Set timezone from config.yml and update time daily using NTP",
      "SUDO   ln -sf /etc/localtime /usr/share/zoneinfo/GB",
      "SUDO   sed -i \"s/UTC=yes/UTC=no/\" /etc/default/rcS",
      "UPLOAD unnamed buffer to /tmp/upload#{@time.to_i}",
      "SUDO   cp /tmp/upload#{@time.to_i} /etc/cron.daily/ntpdate",
      "RUN    rm -f /tmp/upload#{@time.to_i}",
      "SUDO   chmod 755 /etc/cron.daily/ntpdate"
    ]
  end
end

