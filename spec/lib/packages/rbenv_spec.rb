require 'spec_helper'

describe 'packages/rbenv' do
  before(:each) do
    load_package('rbenv')
    AppConf.ruby = AppConf.new
    AppConf.ruby.version = '1.9.2'
    AppConf.ruby.full_version = '1.9.2-p290'
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).must_equal [
      'TASK   rbenv - Install ruby-build, rbenv, ruby 1.9.2 and Bundler',
      "SUDO   apt-get -q -y install git-core",
      'RUN    git clone -q git://github.com/sstephenson/ruby-build.git',
      'SUDO   cd ~/ruby-build && ./install.sh',
      'RUN    git clone -q git://github.com/sstephenson/rbenv.git ~/.rbenv',
      'RUN    echo "export PATH=\\"\\$HOME/.rbenv/bin:\\$PATH\\"" >> ~/.bashrc',
      'RUN    echo "[ -f ~/.bundler-exec.sh ] && source ~/.bundler-exec.sh" >> ~/.bashrc',
      'RUN    echo "eval \\"\\$(rbenv init -)\\"" >> ~/.bashrc',
      'RUN    source ~/.bashrc',

      'RUN    rbenv install 1.9.2-p290',
      'RUN    rbenv rehash',
      'RUN    rbenv global 1.9.2-p290',

      'UPLOAD buffer from .gemrc to .gemrc',
      'RUN    gem install bundler',
      'RUN    wget -q https://github.com/gma/bundler-exec/raw/master/bundler-exec.sh > ~/.bundler-exec.sh',
      'RUN    source ~/.bashrc'
    ]
  end
end

