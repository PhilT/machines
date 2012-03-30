require 'spec_helper'

describe 'packages/virtualbox_guest' do
  before(:each) do
    load_package('virtualbox_guest')
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   virtualbox_guest - Removes piix4_smbus error that appears on Ubuntu VMs when booting",
      'SUDO   echo "blacklist i2c_piix4" >> /etc/modprobe.d/blacklist.conf'
    ]
  end
end

