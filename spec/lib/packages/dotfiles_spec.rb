require 'spec_helper'

describe 'packages/dotfiles' do
  before(:each) do
    load_package('dotfiles')
    AppConf.user = 'username'
    AppConf.appsroot = 'appsroot'
    AppConf.environment = 'railsenv'
    FileUtils.mkdir_p 'users/username/dotfiles'
    FileUtils.touch 'users/username/dotfiles/bashrc'
    FileUtils.touch 'users/username/authorized_keys'
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   dotfiles - Upload files in users/username/dotfiles, prepend a dot and substitute some bashrc vars",
      "UPLOAD #{File.expand_path('users/username/dotfiles/bashrc')} to .bashrc",
      "RUN    sed -i \"s/export RAILS_ENV=/export RAILS_ENV=railsenv/\" .bashrc",
      "RUN    sed -i \"s/export CDPATH=/export CDPATH=appsroot/\" .bashrc",
      "TASK   keyfiles - Upload authorized_keys file",
      "RUN    mkdir -p .ssh",
      "RUN    chmod 700 .ssh",
      "UPLOAD users/username/authorized_keys to .ssh/authorized_keys",
      "RUN    chmod 600 .ssh/authorized_keys",
      "UPLOAD users/username/Pictures to Pictures"
    ]
  end
end

