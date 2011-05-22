require 'spec_helper'

describe 'packages/rvm' do
  include Core
  include FileOperations
  include Configuration
  include Installation
  include Machines::Logger

  before(:each) do
    FakeFS.deactivate!
    @package = File.read(File.join(AppConf.application_dir, 'packages/rvm.rb'))
    FakeFS.activate!
    AppConf.log = mock 'Logger', :puts => nil
    AppConf.user.home = 'user_home'
    AppConf.from_hash(:rvm => {:url => 'rvm_url'})
  end

  it 'adds the following commands' do
    eval @package
    AppConf.commands.map(&:info).should == [
      "SUDO   export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install curl",
      "RUN    bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)",
      "RUN    echo \"[[ -s \"$HOME/.rvm/scripts/rvm\" ]] && . \"$HOME/.rvm/scripts/rvm\" # Load RVM function\" >> user_home/.bashrc",
      "RUN    echo \"export rvm_trust_rvmrcs_flag=1\" >> user_home/.rvmrc",
      "RUN    source user_home/.bashrc"
    ]
  end
end

