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
      "SUDO   echo \"127.0.0.1 localhost.localdomain localhost\" > /etc/hosts",
      "SUDO   echo \"127.0.1.1 hostname\" >> /etc/hosts",
      "SUDO   echo \"hostname\" > /etc/hostname",
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

