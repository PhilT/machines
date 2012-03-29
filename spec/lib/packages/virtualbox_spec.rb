require 'spec_helper'

describe 'packages/virtualbox' do
  before(:each) do
    load_package('virtualbox')
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).must_equal [
      "TASK   virtualbox - Install VirtualBox",
      "SUDO   apt-get -q -y install dkms",
      "SUDO   expr substr `cat /etc/lsb-release | grep DISTRIB_CODENAME` 18 20 | xargs -I DISTRIB_CODENAME echo deb http://download.virtualbox.org/virtualbox/debian DISTRIB_CODENAME contrib >> /etc/apt/sources.list",
      "SUDO   wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O - | apt-key add -",
      "SUDO   apt-get -q -y update > /tmp/apt-update.log",
      "SUDO   apt-get -q -y install virtualbox-4.1",
      "SUDO   usermod -a -G vboxusers phil",
      "SUDO   echo \"application/x-virtualbox-vbox-extpack=virtualbox.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-virtualbox-ova=virtualbox.desktop\" >> .local/share/applications/mimeapps.list"
    ]
  end
end

