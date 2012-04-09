task :usb_policy, 'Allow users to mount USB drives' do
  sudo upload 'misc/udisks.policy', '/usr/share/polkit-1/actions/org.freedesktop.udisks.policy'
  sudo chmod 644, '/usr/share/polkit-1/actions/org.freedesktop.udisks.policy'
end

