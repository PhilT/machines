require 'spec_helper'

describe 'packages/virtualbox_guest' do
  before(:each) do
    load_package('virtualbox_guest')
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   virtualbox_guest - Installs VirtualBox Guest Additions and fixes piix4_smbus error",
      'SUDO   apt-get -q -y install virtualbox-guest-additions',
      'SUDO   grep "blacklist i2c_piix4" /etc/modprobe.d/blacklist.conf || echo "blacklist i2c_piix4" >> /etc/modprobe.d/blacklist.conf'
    ].join("\n")
  end

  it 'autostart client when requested' do
    $conf.confgure_vbox_client = true
    eval_package
    $conf.commands.map(&:info).join("\n").must_match /grep "VBoxClient-all &" .xinitrc || echo "VBoxClient-all &" >> .xinitrc/
  end
end

