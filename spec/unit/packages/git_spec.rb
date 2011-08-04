require 'spec_helper'

describe 'packages/git' do
  include Core
  include FileOperations
  include Configuration
  include Installation
  include Machines::Logger

  before(:each) do
    load_package('git')
    AppConf.log = mock 'Logger', :puts => nil
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "SUDO   export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install git-core"
    ]
  end
end
