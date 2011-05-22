require 'spec_helper'

describe 'packages/mysql' do
  include Core
  include FileOperations
  include Configuration
  include Installation
  include Machines::Logger

  before(:each) do
    FakeFS.deactivate!
    @package = File.read(File.join(AppConf.application_dir, 'packages/mysql.rb'))
    FakeFS.activate!
    AppConf.log = mock 'Logger', :puts => nil
  end

  it 'adds the following commands' do
    pending
    eval @package
    AppConf.commands.map(&:info).should == [
    ]
  end
end

