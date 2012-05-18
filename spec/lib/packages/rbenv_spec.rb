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
    $conf.commands.map(&:info).join("\n").must_equal [
      'TASK   rbenv - Install ruby-build, rbenv, ruby 1.9.2 and Bundler',
      "SUDO   apt-get -q -y install git-core",
      "SUDO   apt-get -q -y install curl",
      'RUN    git clone --quiet git://github.com/sstephenson/ruby-build.git',
      'SUDO   cd ~/ruby-build && ./install.sh',
      'RUN    git clone --quiet git://github.com/sstephenson/rbenv.git ~/.rbenv',
      'RUN    echo "PATH=.git/safe/../../.bin:\\$HOME/.rbenv/bin:\\$HOME/.rbenv/shims:\\$PATH" >> ~/.profile',

      'RUN    $HOME/.rbenv/bin/rbenv install 1.9.2-p290',
      'RUN    $HOME/.rbenv/bin/rbenv rehash',
      'RUN    $HOME/.rbenv/bin/rbenv global 1.9.2-p290',

      'UPLOAD buffer from .gemrc to .gemrc',
      'RUN    $HOME/.rbenv/bin/rbenv exec gem install bundler',
      'RUN    $HOME/.rbenv/bin/rbenv rehash'
    ].join("\n")
  end
end

