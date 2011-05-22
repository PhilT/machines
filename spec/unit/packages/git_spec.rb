require 'spec_helper'

describe 'packages/git' do
  include Core
  include FileOperations
  include Configuration
  include Installation
  include Machines::Logger

  before(:each) do
    FakeFS.deactivate!
    @package = File.read(File.join(AppConf.application_dir, 'packages/git.rb'))
    FakeFS.activate!
    AppConf.log = mock 'Logger', :puts => nil
  end

  it 'adds the following commands' do
    eval @package
    AppConf.commands.map(&:info).should == [
      "SUDO   export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install git-core"
    ]
  end
end

