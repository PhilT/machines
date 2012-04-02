require 'spec_helper'

describe 'packages/rbenv' do
  before(:each) do
    load_package('rbenv')
    $conf.ruby = AppConf.new
    $conf.ruby.version = '1.9.2'
    $conf.ruby.full_version = '1.9.2-p290'
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      'TASK   rbenv - Install ruby-build, rbenv, ruby 1.9.2 and Bundler',
      "SUDO   apt-get -q -y install git-core",
      'RUN    git clone -q git://github.com/sstephenson/ruby-build.git',
      'SUDO   cd ~/ruby-build && ./install.sh',
      'RUN    git clone -q git://github.com/sstephenson/rbenv.git ~/.rbenv',
      'RUN    echo "export PATH=\\".git/safe/../../.bin:\\$HOME/.rbenv/bin:\\$HOME/.rbenv/shims:\\$PATH\\"" >> ~/.profile',
      'RUN    source ~/.profile',

      'RUN    rbenv install 1.9.2-p290',
      'RUN    rbenv rehash',
      'RUN    rbenv global 1.9.2-p290',

      'UPLOAD buffer from .gemrc to .gemrc',
      'RUN    gem install bundler',
    ]
  end
end

