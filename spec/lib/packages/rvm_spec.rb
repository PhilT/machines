require 'spec_helper'

describe 'packages/rvm' do
  before(:each) do
    load_package('rvm')
    AppConf.from_hash(:ruby => {:version => '1.9'})
    AppConf.from_hash(:rvm => {:url => 'rvm_url', :version => '1.0'})
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   rvm - Install RVM",
      "SUDO   apt-get -q -y install git-core",
      'RUN    bash -s 1.0 < <(wget -q https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )',

      "RUN    source .bashrc",
      "RUN    rm -rf rvm-installer",

      "TASK   rvm_prompt_off - turn off trust prompting for new .rvmrc files",
      "RUN    echo \"export rvm_trust_rvmrcs_flag=1\" >> .rvmrc",

      'TASK   ruby - Install Ruby, make 1.9@global the default and install Bundler',
      'RUN    rvm install 1.9',
      'RUN    rvm 1.9@global --default',
      'UPLOAD buffer from .gemrc to .gemrc',
      'RUN    gem install bundler'
    ]
  end
end

