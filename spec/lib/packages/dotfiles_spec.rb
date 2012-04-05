require 'spec_helper'

describe 'packages/dotfiles' do
  before(:each) do
    load_package('dotfiles')
    $conf.machine = AppConf.new
    $conf.machine.user = 'username'
    $conf.appsroot = 'appsroot'
    $conf.environment = 'railsenv'
    $conf.from_hash(:hosts => {'somehost' => '1.1.1.1'})

    FileUtils.mkdir_p 'users/username/dotfiles'
    FileUtils.touch 'users/username/dotfiles/bashrc'
    FileUtils.touch 'users/username/authorized_keys'
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   dotfiles - Upload files in users/username/dotfiles, prepend a dot and substitute some bashrc vars",
      "UPLOAD #{File.expand_path('users/username/dotfiles/bashrc')} to .bashrc",
      "RUN    mkdir -p $HOME/.ssh",
      "RUN    chmod 700 $HOME/.ssh",
      "RUN    ssh-keyscan -H somehost >> $HOME/.ssh/known_hosts",
      "RUN    echo \"export RAILS_ENV=railsenv\" >> .profile",
      "RUN    echo \"export CDPATH=appsroot\" >> .profile",
      "UPLOAD users/username/authorized_keys to .ssh/authorized_keys",
      "RUN    chmod 600 .ssh/authorized_keys"
    ].join("\n")
  end
end

