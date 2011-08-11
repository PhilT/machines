require 'spec_helper'

describe 'packages/base' do
  before(:each) do
    load_package('base')
    AppConf.hostname = 'hostname'
    AppConf.log = mock 'Logger', :puts => nil
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:command).should == ["ln -sf /etc/localtime /usr/share/zoneinfo/",
      "sed -i \"s/UTC=yes/UTC=no/\" /etc/default/rcS",
      "echo \"127.0.0.1 localhost.localdomain localhost\" > /etc/hosts",
      "echo \"127.0.1.1 hostname\" >> /etc/hosts",
      "echo \"hostname\" > /etc/hostname",
      "service hostname start",
      "export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install build-essential",
      "apt-get -q -y install zlib1g-dev",
      "apt-get -q -y install libpcre3-dev",
      "apt-get -q -y install libreadline5-dev",
      "apt-get -q -y install libxml2-dev",
      "apt-get -q -y install libxslt1-dev",
      "apt-get -q -y install libssl-dev"
    ]
  end
end

