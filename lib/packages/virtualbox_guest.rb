task :virtualbox_guest, 'Removes piix4_smbus error that appears on Ubuntu VMs when booting' do
  sudo append 'blacklist i2c_piix4', :to => '/etc/modprobe.d/blacklist.conf'
end

