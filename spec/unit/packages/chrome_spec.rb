require 'spec_helper'

describe 'packages/chrome' do
  include Core
  include FileOperations
  include Configuration
  include Installation
  include Machines::Logger

  before(:each) do
    FakeFS.deactivate!
    @package = File.read(File.join(AppConf.application_dir, 'packages/chrome.rb'))
    FakeFS.activate!
    AppConf.log = mock 'Logger', :puts => nil
  end

  it 'adds the following commands' do
    eval @package
    AppConf.commands.map(&:command).should == [
      "echo deb http://dl.google.com/linux/deb/ stable main >> /etc/apt/sources.list",
      "wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub -O - | apt-key add -",
      "export DEBIAN_FRONTEND=noninteractive && apt-get -q -y update",
      "export DEBIAN_FRONTEND=noninteractive && apt-get -q -y upgrade",
      "export DEBIAN_FRONTEND=noninteractive && apt-get -q -y autoremove",
      "export DEBIAN_FRONTEND=noninteractive && apt-get -q -y autoclean",
      "export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install google-chrome-stable"
    ]
  end
end

