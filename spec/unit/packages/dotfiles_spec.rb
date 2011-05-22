require 'spec_helper'

describe 'packages/dotfiles' do
  include Core
  include FileOperations
  include Configuration
  include Installation
  include Machines::Logger

  before(:each) do
    FakeFS.deactivate!
    @package = File.read(File.join(AppConf.application_dir, 'packages/dotfiles.rb'))
    FakeFS.activate!
    AppConf.log = mock 'Logger', :puts => nil
    AppConf.from_hash(:user => {:name => 'username', :home => 'home_dir', :appsroot => 'appsroot'})
    AppConf.dotfiles = %w(bashrc gitconfig)
    AppConf.environment = 'railsenv'
    FileUtils.mkdir_p '/tmp/users/username'
    FileUtils.touch '/tmp/users/username/bashrc'
    FileUtils.touch '/tmp/users/username/authorized_keys'
  end

  it 'adds the following commands' do
    eval @package
    AppConf.commands.map(&:command).should == [
      nil,
      "sed -i \"s/export RAILS_ENV=/export RAILS_ENV=railsenv/\" home_dir/.bashrc",
      "sed -i \"s/export CDPATH=/export CDPATH=appsroot/\" home_dir/.bashrc",
      "mkdir -p home_dir/.ssh",
      "chmod 700 home_dir/.ssh",
      nil,
      "chmod 600 home_dir/.ssh/authorized_keys"
    ]
    AppConf.commands.first.local.should == '/tmp/users/username/bashrc'
    AppConf.commands.first.remote.should == 'home_dir/.bashrc'
    AppConf.commands[5].local.should == '/tmp/users/username/authorized_keys'
    AppConf.commands[5].remote.should == 'home_dir/.ssh/authorized_keys'
  end
end

