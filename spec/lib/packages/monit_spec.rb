require 'spec_helper'

describe 'packages/monit' do
  before(:each) do
    load_package('monit')
    FileUtils.mkdir_p '/prj/monit'
    File.open('/prj/monit/monitrc.erb', 'w') {|f| f.puts 'the template' }
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   monit - Install and configure monit",
      "SUDO   apt-get -q -y install monit",
      "UPLOAD buffer from /prj/monit/monitrc.erb to /tmp/monitrc",
      "SUDO   cp -f /tmp/monitrc /etc/monit/monitrc",
      "RUN    rm -f /tmp/monitrc",
      "SUDO   sed -i \"s/startup=0/startup=1/\" /etc/default/monit"
    ]
  end
end

