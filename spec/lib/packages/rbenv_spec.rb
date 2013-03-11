require 'spec_helper'

describe 'packages/rbenv' do
  before(:each) do
    $conf.ruby = AppConf.new
    $conf.ruby.version = '1.9.2'
    $conf.ruby.build = 'p290'
    eval_package
  end

  it 'sets gems_path' do
    $conf.ruby.gems_path.must_equal '.rbenv/versions/1.9.2-p290/lib/ruby/gems/1.9.1/gems'
  end

  it 'sets executable' do
    $conf.ruby.executable.must_equal '.rbenv/versions/1.9.2-p290/bin/ruby'
  end

  it 'adds the following commands' do
    $conf.commands.map(&:info).join("\n").must_equal [
      'TASK   rbenv - Install ruby-build, rbenv, ruby 1.9.2-p290 and Bundler',
      "SUDO   apt-get -q -y install git-core",
      "SUDO   apt-get -q -y install curl",
      'RUN    test -d ruby-build && (cd ruby-build && git pull) || git clone --quiet git://github.com/sstephenson/ruby-build.git',
      'SUDO   cd ~/ruby-build && ./install.sh',
      'RUN    test -d ~/.rbenv && (cd ~/.rbenv && git pull) || git clone --quiet git://github.com/sstephenson/rbenv.git ~/.rbenv',
      'RUN    grep "PATH=.bin/safe/../../.bin:\\$HOME/.rbenv/bin:\\$HOME/.rbenv/shims:\\$PATH" ~/.profile || echo "PATH=.bin/safe/../../.bin:\\$HOME/.rbenv/bin:\\$HOME/.rbenv/shims:\\$PATH" >> ~/.profile',

      'RUN    $HOME/.rbenv/bin/rbenv install 1.9.2-p290',
      'RUN    $HOME/.rbenv/bin/rbenv rehash',
      'RUN    $HOME/.rbenv/bin/rbenv global 1.9.2-p290',

      'UPLOAD buffer from .gemrc to .gemrc',
      'RUN    $HOME/.rbenv/bin/rbenv exec gem install bundler',
      'RUN    $HOME/.rbenv/bin/rbenv rehash'
    ].join("\n")
  end
end

