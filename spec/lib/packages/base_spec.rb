require 'spec_helper'

describe 'packages/base' do
  before(:each) do
    load_package('base')
    AppConf.machine = AppConf.new
    AppConf.machine.hostname = 'hostname'
    AppConf.hosts = ['1.2.3.4 some.domain']
    @hosts = [
      "TASK   hosts - Set /etc/hosts",
      "UPLOAD unnamed buffer to /tmp/hosts",
      "SUDO   cp -rf /tmp/hosts /etc/hosts",
      "RUN    rm -rf /tmp/hosts",
      "UPLOAD unnamed buffer to /tmp/hostname",
      "SUDO   cp -rf /tmp/hostname /etc/hostname",
      "RUN    rm -rf /tmp/hostname",
      "SUDO   service hostname start",
      "SUDO   echo \"1.2.3.4 some.domain\" >> /etc/hosts",
    ]
    @packages = [
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

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).must_equal @hosts + @packages
  end

  it 'does not add hosts when nil' do
    AppConf.hosts = nil
    @hosts.pop
    eval_package
    AppConf.commands.map(&:info).must_equal @hosts + @packages
  end
end

