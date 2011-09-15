require 'spec_helper'

describe 'packages/virtual_box' do
  before(:each) do
    load_package('virtual_box')
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   virtual_box - Install VirtualBox",
      "SUDO   apt-get -q -y install dkms",
      "SUDO   expr substr `cat /etc/lsb-release | grep DISTRIB_CODENAME` 18 20 | xargs -I DISTRIB_CODENAME echo deb http://download.virtualbox.org/virtualbox/debian DISTRIB_CODENAME contrib >> /etc/apt/sources.list",
      "SUDO   wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O - | apt-key add -",
      "SUDO   apt-get -q -y update > /tmp/apt-update.log",
      "SUDO   apt-get -q -y install virtualbox-4.1",
      "SUDO   usermod -a -G phil vboxusers"
    ]
  end
end

