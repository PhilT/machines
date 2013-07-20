require 'spec_helper'

describe 'packages/dotfiles' do
  before(:each) do
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
    queued_commands.must_equal [
      "TASK   dotfiles - Upload users/username/dotfiles and set some env vars",
      "UPLOAD users/username/dotfiles/bashrc to .bashrc",
      "RUN    mkdir -p $HOME/.ssh",
      "RUN    chmod 700 $HOME/.ssh",
      "RUN    ssh-keyscan -H somehost >> $HOME/.ssh/known_hosts",
      "RUN    grep \"export RAILS_ENV=railsenv\" .profile || echo \"export RAILS_ENV=railsenv\" >> .profile",
      "RUN    grep \"export CDPATH=appsroot\" .profile || echo \"export CDPATH=appsroot\" >> .profile",
      "UPLOAD users/username/authorized_keys to .ssh/authorized_keys",
      "RUN    chmod 600 .ssh/authorized_keys"
    ].join("\n")
  end

  it 'sets RAILS_ENV when specified in set_rails_env_for' do
    $conf.set_rails_env_for = ['railsenv']
    eval_package
    expected = /RUN    grep \"export RAILS_ENV=railsenv\" .profile || echo \"export RAILS_ENV=railsenv\" >> .profile/
    queued_commands.must_match expected
  end

  it 'RAILS_ENV not set when not specified in set_rails_env_for' do
    $conf.set_rails_env_for = ['some_other_env']
    eval_package
    expected = /RUN    grep \"export RAILS_ENV=railsenv\" .profile \|\| echo \"export RAILS_ENV=railsenv\" >> .profile/
    queued_commands.wont_match expected
  end
end

