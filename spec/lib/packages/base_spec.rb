require 'spec_helper'

describe 'packages/base' do
  before(:each) do
    load_package('base')
    AppConf.localhosts = ['host1.local', 'host2.local']
    AppConf.hostname = 'hostname'
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   hosts - Set /etc/hosts",
      "UPLOAD unnamed buffer to /tmp/hosts",
      "SUDO   cp -rf /tmp/hosts /etc/hosts",
      "RUN    rm -rf /tmp/hosts",
      "UPLOAD unnamed buffer to /tmp/hostname",
      "SUDO   cp -rf /tmp/hostname /etc/hostname",
      "RUN    rm -rf /tmp/hostname",
      "SUDO   service hostname start",
      "TASK   base - Install base packages",
      "SUDO   apt-get -q -y install build-essential",
      "SUDO   apt-get -q -y install zlib1g-dev",
      "SUDO   apt-get -q -y install libpcre3-dev",
      "SUDO   apt-get -q -y install libreadline5-dev",
      "SUDO   apt-get -q -y install libxml2-dev",
      "SUDO   apt-get -q -y install libxslt1-dev",
      "SUDO   apt-get -q -y install libssl-dev",
    ]
  end

  it 'adds localhosts to /etc/hosts' do
    AppConf.environment = :development
    eval_package
    AppConf.commands.map(&:info).should include 'SUDO   echo "127.0.0.1 host1.local" >> /etc/hosts'
    AppConf.commands.map(&:info).should include 'SUDO   echo "127.0.0.1 host2.local" >> /etc/hosts'
  end
end

