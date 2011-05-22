require 'spec_helper'

describe 'packages/passenger' do
  include Core
  include FileOperations
  include Configuration
  include Installation
  include Machines::Logger

  before(:each) do
    FakeFS.deactivate!
    @package = File.read(File.join(AppConf.application_dir, 'packages/passenger.rb'))
    FakeFS.activate!
    AppConf.log = mock 'Logger', :puts => nil
    AppConf.from_hash(:passenger => {:version => '3.0.7'})
  end

  it 'adds the following commands' do
    eval @package
    AppConf.commands.map(&:info).should == [
      "SUDO   export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install libcurl4-openssl-dev",
      "RUN    gem install passenger -v \"3.0.7\""
    ]
  end
end

