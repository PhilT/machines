require 'spec_helper'

describe 'packages/monit' do
  before(:each) do
    load_package('monit')
    FileUtils.mkdir_p '/prj/monit/conf.d'
    File.open('/prj/monit/monitrc.erb', 'w') {}
    File.open('/prj/monit/conf.d/system.erb', 'w') {}
    File.open('/prj/monit/conf.d/ssh', 'w') {}
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   monit - Install and configure monit",
      "SUDO   apt-get -q -y install monit",
      "UPLOAD buffer from /prj/monit/monitrc.erb to /tmp/monitrc",
      "SUDO   cp -f /tmp/monitrc /etc/monit/monitrc",
      "RUN    rm -f /tmp/monitrc",
      "UPLOAD buffer from /prj/monit/conf.d/system.erb to /tmp/system",
      "SUDO   cp -f /tmp/system /etc/monit/conf.d/system",
      "RUN    rm -f /tmp/system",
      "UPLOAD /prj/monit/conf.d/ssh to /tmp/ssh",
      "SUDO   cp -f /tmp/ssh /etc/monit/conf.d/ssh",
      "RUN    rm -f /tmp/ssh",
      "SUDO   ",
      "SUDO   sed -i \"s/startup=0/startup=1/\" /etc/default/monit"
    ]
  end
end

