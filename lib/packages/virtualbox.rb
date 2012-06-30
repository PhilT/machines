task :virtualbox, 'Install VirtualBox' do
  sudo install %w(dkms) # Ensures kernal modules are updated when upgrading virtual box

  sudo add_ppa 'debfx/virtualbox', 'felix'

  sudo install 'virtualbox'
  sudo add :user => $conf.user, :to => 'vboxusers'
  sudo append 'application/x-virtualbox-vbox-extpack=virtualbox.desktop', :to => '.local/share/applications/mimeapps.list'
  sudo append 'application/x-virtualbox-ova=virtualbox.desktop', :to => '.local/share/applications/mimeapps.list'
end

