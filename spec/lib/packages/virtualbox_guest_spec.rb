require 'spec_helper'

describe 'packages/virtualbox_guest' do
  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   virtualbox_guest - Installs VirtualBox Guest Additions and fixes piix4_smbus error",
      "SUDO   echo deb http://download.virtualbox.org/virtualbox/debian precise contrib >> /etc/apt/sources.list",
      "SUDO   wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O - | apt-key add -",
      "SUDO   apt-get -q -y update > /tmp/apt-update.log",
      'SUDO   apt-get -q -y install virtualbox-guest-additions-x11',
      'SUDO   grep "blacklist i2c_piix4" /etc/modprobe.d/blacklist.conf || echo "blacklist i2c_piix4" >> /etc/modprobe.d/blacklist.conf'
    ].join("\n")
  end

  it 'autostart client when requested' do
    $conf.confgure_vbox_client = true
    eval_package
    $conf.commands.map(&:info).join("\n").must_match /grep "VBoxClient-all &" .xinitrc || echo "VBoxClient-all &" >> .xinitrc/
  end
end

