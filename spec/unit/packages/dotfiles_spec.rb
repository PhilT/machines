require 'spec_helper'

describe 'packages/dotfiles' do
  include Core
  include FileOperations
  include Configuration
  include Installation
  include Machines::Logger

  before(:each) do
    load_package('dotfiles')
    AppConf.log = mock 'Logger', :puts => nil
    AppConf.from_hash(:user => {:name => 'username', :home => 'home_dir', :appsroot => 'appsroot'})
    AppConf.environment = 'railsenv'
    FileUtils.mkdir_p '/tmp/users/username/dotfiles'
    FileUtils.touch '/tmp/users/username/dotfiles/bashrc'
    FileUtils.touch '/tmp/users/username/authorized_keys'
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "UPLOAD /tmp/users/username/dotfiles/bashrc to home_dir/.bashrc",
      "RUN    sed -i \"s/export RAILS_ENV=/export RAILS_ENV=railsenv/\" home_dir/.bashrc",
      "RUN    sed -i \"s/export CDPATH=/export CDPATH=appsroot/\" home_dir/.bashrc",
      "RUN    mkdir -p home_dir/.ssh",
      "RUN    chmod 700 home_dir/.ssh",
      "UPLOAD /tmp/users/username/authorized_keys to home_dir/.ssh/authorized_keys",
      "RUN    chmod 600 home_dir/.ssh/authorized_keys"
    ]
  end
end

