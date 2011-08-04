require 'spec_helper'

describe 'packages/firefox' do
  include Core
  include FileOperations
  include Configuration
  include Installation
  include Machines::Logger

  before(:each) do
    load_package('firefox')
    AppConf.log = mock 'Logger', :puts => nil
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "SUDO   add-apt-repository ppa:mozillateam/firefox-stable",
      "SUDO   export DEBIAN_FRONTEND=noninteractive && apt-get -q -y update",
      "SUDO   export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install firefox"
    ]
  end
end
