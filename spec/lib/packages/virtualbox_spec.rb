require 'spec_helper'

describe 'packages/virtualbox' do
  before(:each) do
    load_package('virtualbox')
    $conf.user = 'phil'
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   virtualbox - Install VirtualBox",
      "SUDO   apt-get -q -y install dkms",
      "SUDO   add-apt-repository -y ppa:debfx/virtualbox",
      "SUDO   apt-get -q -y update > /tmp/apt-update.log",
      "SUDO   apt-get -q -y install virtualbox",
      "SUDO   usermod -a -G vboxusers phil",
      "SUDO   grep \"application/x-virtualbox-vbox-extpack=virtualbox.desktop\" .local/share/applications/mimeapps.list || echo \"application/x-virtualbox-vbox-extpack=virtualbox.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   grep \"application/x-virtualbox-ova=virtualbox.desktop\" .local/share/applications/mimeapps.list || echo \"application/x-virtualbox-ova=virtualbox.desktop\" >> .local/share/applications/mimeapps.list"
    ].join("\n")
  end
end

