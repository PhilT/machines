require 'spec_helper'

describe 'packages/rvm' do
  before(:each) do
    load_package('rvm')
    AppConf.from_hash(:rvm => {:url => 'rvm_url', :version => '1.0'})
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   rvm - Install RVM",
      "SUDO   apt-get -q -y install git-core",
      "SUDO   apt-get -q -y install curl",
      "RUN    curl -s rvm_url -o rvm-installer ; chmod +x rvm-installer ; ./rvm-installer --version 1.0",
      "RUN    source .bashrc",
      "RUN    rm -rf rvm-installer",
      "TASK   rvm_prompt_off - turn off trust prompting for new .rvmrc files",
      "RUN    echo \"export rvm_trust_rvmrcs_flag=1\" >> .rvmrc",
    ]
  end
end

