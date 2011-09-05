require 'spec_helper'

describe 'packages/base' do
  before(:each) do
    load_package('base')
    AppConf.hostname = 'hostname'
    @time = Time.now
    Time.stub(:now).and_return @time
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   hosts - Set /etc/hosts",
      "UPLOAD unnamed buffer to /tmp/upload#{@time.to_i}",
      "SUDO   cp /tmp/upload#{@time.to_i} /etc/hosts",
      "RUN    rm -f /tmp/upload#{@time.to_i}",
      "UPLOAD unnamed buffer to /tmp/upload#{@time.to_i}",
      "SUDO   cp /tmp/upload#{@time.to_i} /etc/hostname",
      "RUN    rm -f /tmp/upload#{@time.to_i}",
      "SUDO   service hostname start",
      "TASK   base - Install base packages",
      "SUDO   apt-get -q -y install build-essential",
      "SUDO   apt-get -q -y install zlib1g-dev",
      "SUDO   apt-get -q -y install libpcre3-dev",
      "SUDO   apt-get -q -y install debconf-utils",
      "SUDO   apt-get -q -y install libreadline5-dev",
      "SUDO   apt-get -q -y install libxml2-dev",
      "SUDO   apt-get -q -y install libxslt1-dev",
      "SUDO   apt-get -q -y install libssl-dev"
    ]
  end
end

