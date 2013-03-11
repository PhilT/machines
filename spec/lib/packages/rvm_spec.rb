require 'spec_helper'

describe 'packages/rvm' do
  before(:each) do
    $conf.from_hash(ruby: {version: '1.9.2', build: 'p290'})
    $conf.from_hash(rvm: {version:  '1.0'})
    eval_package
  end

  it 'sets gems_path' do
    $conf.ruby.gems_path.must_equal '.rvm/gems/1.9.2-p290/@global/gems'
  end

  it 'sets executable' do
    $conf.ruby.executable.must_equal '.rvm/wrappers/1.9.2-p290@global/ruby'
  end

  it 'adds the following commands' do
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   rvm - Install RVM",
      "SUDO   apt-get -q -y install git-core",
      'RUN    bash -s 1.0 < <(wget -q https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )',

      "RUN    source .bashrc",
      "RUN    rm -rf rvm-installer",

      "TASK   rvm_prompt_off - turn off trust prompting for new .rvmrc files",
      "RUN    grep \"export rvm_trust_rvmrcs_flag=1\" .rvmrc || echo \"export rvm_trust_rvmrcs_flag=1\" >> .rvmrc",

      'TASK   ruby - Install Ruby, make 1.9.2-p290@global the default and install Bundler',
      'RUN    rvm install 1.9.2',
      'RUN    rvm 1.9.2@global --default',
      'UPLOAD buffer from .gemrc to .gemrc',
      'RUN    gem install bundler'
    ].join("\n")
  end
end

