task :virtualbox_guest, 'Installs VirtualBox Guest Additions and fixes piix4_smbus error' do
  sudo install ['virtualbox-guest-additions']
  sudo append 'blacklist i2c_piix4', :to => '/etc/modprobe.d/blacklist.conf'
  run append 'VBoxClient-all &', to: '.xinitrc' if $conf.autostart_vbox_client
end

