task :virtualbox, 'Install VirtualBox' do
  sudo install %w(dkms) # Ensures kernal modules are updated when upgrading virtual box
  sudo deb 'http://download.virtualbox.org/virtualbox/debian DISTRIB_CODENAME contrib non-free',
    :key => 'http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc',
    :name => 'VirtualBox'
  sudo update

  sudo install 'virtualbox-4.0'
end

