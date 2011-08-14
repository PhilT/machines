require 'spec_helper'

describe 'packages/rvm' do
  before(:each) do
    load_package('rvm')
    AppConf.log = mock 'Logger', :puts => nil
    AppConf.user.home = 'user_home'
    AppConf.from_hash(:rvm => {:url => 'rvm_url'})
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "\nTASK   rvm - Install RVM",
      "SUDO   export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install curl",
      "RUN    bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)",
      "RUN    echo \"[[ -s \"$HOME/.rvm/scripts/rvm\" ]] && . \"$HOME/.rvm/scripts/rvm\" # Load RVM function\" >> user_home/.bashrc",
      "RUN    source user_home/.bashrc",
      "\nTASK   rvm_prompt_off - turn off trust prompting for new .rvmrc files",
      "RUN    echo \"export rvm_trust_rvmrcs_flag=1\" >> user_home/.rvmrc",
    ]
  end
end

