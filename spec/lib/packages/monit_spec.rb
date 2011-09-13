require 'spec_helper'

describe 'packages/monit' do
  before(:each) do
    load_package('monit')
    FileUtils.mkdir_p 'monit/conf.d'
    File.open('monit/monitrc.erb', 'w') {}
    File.open('monit/conf.d/system.erb', 'w') {}
    File.open('monit/conf.d/ssh', 'w') {}
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   monit - Install and configure monit",
      "SUDO   apt-get -q -y install monit",
      "UPLOAD buffer from monit/monitrc.erb to /tmp/monitrc",
      "SUDO   cp -rf /tmp/monitrc /etc/monit/monitrc",
      "RUN    rm -rf /tmp/monitrc",
      "UPLOAD buffer from monit/conf.d/system.erb to /tmp/system",
      "SUDO   cp -rf /tmp/system /etc/monit/conf.d/system",
      "RUN    rm -rf /tmp/system",
      "UPLOAD monit/conf.d/ssh to /tmp/ssh",
      "SUDO   cp -rf /tmp/ssh /etc/monit/conf.d/ssh",
      "RUN    rm -rf /tmp/ssh",
      "SUDO   echo dummy",
      "SUDO   sed -i \"s/startup=0/startup=1/\" /etc/default/monit"
    ]
  end
end

