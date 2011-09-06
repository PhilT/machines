require 'spec_helper'

describe 'packages/base' do
  before(:each) do
    load_package('base')
    AppConf.hostname = 'hostname'
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   hosts - Set /etc/hosts",
      "UPLOAD unnamed buffer to /tmp/hosts",
      "SUDO   cp /tmp/hosts /etc/hosts",
      "RUN    rm -f /tmp/hosts",
      "UPLOAD unnamed buffer to /tmp/hostname",
      "SUDO   cp /tmp/hostname /etc/hostname",
      "RUN    rm -f /tmp/hostname",
      "SUDO   service hostname start",
      "TASK   base - Install base packages",
      "SUDO   apt-get -q -y update > /tmp/apt-update.log",
      "SUDO   apt-get -q -y install build-essential",
      "SUDO   apt-get -q -y install zlib1g-dev",
      "SUDO   apt-get -q -y install libpcre3-dev",
      "SUDO   apt-get -q -y install debconf-utils",
      "SUDO   apt-get -q -y install libreadline5-dev",
      "SUDO   apt-get -q -y install libxml2-dev",
      "SUDO   apt-get -q -y install libxslt1-dev",
      "SUDO   apt-get -q -y install libssl-dev",
      "SUDO   apt-get -q -y install python-software-properties"
    ]
  end
end

