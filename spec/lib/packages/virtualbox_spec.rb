require 'spec_helper'

describe 'packages/virtualbox' do
  before(:each) do
    $conf.user = 'phil'
    eval_package
  end

  it 'adds the following commands' do
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   virtualbox - Install VirtualBox",
      "SUDO   apt-get -q -y install dkms",
      "SUDO   echo deb http://download.virtualbox.org/virtualbox/debian precise contrib >> /etc/apt/sources.list",
      "SUDO   wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O - | apt-key add -",
      "SUDO   apt-get -q -y update > /tmp/apt-update.log",
      "SUDO   apt-get -q -y install virtualbox",
      "SUDO   usermod -a -G vboxusers phil",
      "SUDO   grep \"application/x-virtualbox-vbox-extpack=virtualbox.desktop\" .local/share/applications/mimeapps.list || echo \"application/x-virtualbox-vbox-extpack=virtualbox.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   grep \"application/x-virtualbox-ova=virtualbox.desktop\" .local/share/applications/mimeapps.list || echo \"application/x-virtualbox-ova=virtualbox.desktop\" >> .local/share/applications/mimeapps.list"
    ].join("\n")
  end
end

