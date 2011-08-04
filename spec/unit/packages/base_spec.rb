require 'spec_helper'

describe 'packages/base' do
  include Core
  include FileOperations
  include Configuration
  include Installation
  include Machines::Logger

  before(:each) do
    load_package('base')
    AppConf.hostname = 'hostname'
    AppConf.log = mock 'Logger', :puts => nil
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:command).should == ["ln -sf /etc/localtime /usr/share/zoneinfo/",
      "sed -i \"s/UTC=yes/UTC=no/\" /etc/default/rcS",
      "echo \"hostname\" > /etc/hostname",
      "hostname hostname",
      "echo \"127.0.1.1\thostname\" > /etc/hosts",
      "echo \"127.0.0.1\tlocalhost\" >> /etc/hosts",
      "export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install build-essential",
      "export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install zlib1g-dev",
      "export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install libpcre3-dev",
      "export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install libreadline5-dev",
      "export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install libxml2-dev",
      "export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install libxslt1-dev",
      "export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install libssl-dev"
    ]
  end
end

