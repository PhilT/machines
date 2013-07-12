task :virtualbox_guest, 'Installs VirtualBox Guest Additions and fixes piix4_smbus error' do
  sudo deb 'http://download.virtualbox.org/virtualbox/debian precise contrib',
    key: 'http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc',
    name: 'VirtualBox'

  sudo install 'virtualbox-guest-additions-x11'
  sudo append 'blacklist i2c_piix4', to: '/etc/modprobe.d/blacklist.conf'
end

