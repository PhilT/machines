require 'spec_helper'

describe 'packages/monit' do
  before(:each) do
    FileUtils.mkdir_p 'monit/conf.d'
    File.open('monit/monitrc.erb', 'w') {}
    File.open('monit/upstart.conf.erb', 'w') {}
    File.open('monit/conf.d/system.erb', 'w') {}
    File.open('monit/conf.d/ssh', 'w') {}
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   monit - Install and configure monit",
      "SUDO   apt-get -q -y install monit",
      "SUDO   /etc/init.d/monit stop && update-rc.d -f monit remove",
      "UPLOAD monit/upstart.conf to /tmp/monit.conf",
      "SUDO   cp -rf /tmp/monit.conf /etc/init/monit.conf",
      "RUN    rm -rf /tmp/monit.conf",
      "UPLOAD buffer from monit/monitrc.erb to /tmp/monitrc",
      "SUDO   cp -rf /tmp/monitrc /etc/monit/monitrc",
      "RUN    rm -rf /tmp/monitrc",
      "UPLOAD buffer from monit/conf.d/system.erb to /tmp/system",
      "SUDO   cp -rf /tmp/system /etc/monit/conf.d/system",
      "RUN    rm -rf /tmp/system",
      "UPLOAD monit/conf.d/ssh to /tmp/ssh",
      "SUDO   cp -rf /tmp/ssh /etc/monit/conf.d/ssh",
      "RUN    rm -rf /tmp/ssh"
    ].join("\n")
  end
end

