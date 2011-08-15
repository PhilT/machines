require 'spec_helper'

describe 'packages/apps' do
  before(:each) do
    load_package('apps')
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "\nTASK   apps - Install apps for minimal development machine",
      "SUDO   export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install abiword",
      "SUDO   apt-get -q -y install audacious",
      "SUDO   apt-get -q -y install brasero",
      "SUDO   apt-get -q -y install evince",
      "SUDO   apt-get -q -y install file-roller",
      "SUDO   apt-get -q -y install flashplugin-installer",
      "SUDO   apt-get -q -y install gedit",
      "SUDO   apt-get -q -y install gimp",
      "SUDO   apt-get -q -y install gitk",
      "SUDO   apt-get -q -y install gnumeric",
      "SUDO   apt-get -q -y install inkscape",
      "SUDO   apt-get -q -y install libsqlite3-dev",
      "SUDO   apt-get -q -y install meld",
      "SUDO   apt-get -q -y install mysql-query-browser",
      "SUDO   apt-get -q -y install terminator",
      "SUDO   apt-get -q -y install ubuntu-restricted-extras"
    ]
  end
end

