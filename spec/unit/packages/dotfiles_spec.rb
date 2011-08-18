require 'spec_helper'

describe 'packages/dotfiles' do
  before(:each) do
    load_package('dotfiles')
    AppConf.from_hash(:user => {:name => 'username', :home => 'home_dir', :appsroot => 'appsroot'})
    AppConf.appsroot = 'appsroot'
    AppConf.environment = 'railsenv'
    FileUtils.mkdir_p '/prj/users/username/dotfiles'
    FileUtils.touch '/prj/users/username/dotfiles/bashrc'
    FileUtils.touch '/prj/users/username/authorized_keys'
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   dotfiles - Upload files in users/name/username/dotfiles, prepend a dot and substitute some bashrc vars",
      "UPLOAD /prj/users/username/dotfiles/bashrc to home_dir/.bashrc",
      "RUN    sed -i \"s/export RAILS_ENV=/export RAILS_ENV=railsenv/\" home_dir/.bashrc",
      "RUN    sed -i \"s/export CDPATH=/export CDPATH=appsroot/\" home_dir/.bashrc",
      "TASK   keyfiles - Upload authorized_keys file",
      "RUN    mkdir -p home_dir/.ssh",
      "RUN    chmod 700 home_dir/.ssh",
      "UPLOAD /prj/users/username/authorized_keys to home_dir/.ssh/authorized_keys",
      "RUN    chmod 600 home_dir/.ssh/authorized_keys"
    ]
  end
end

