task :shutdown_no_password, 'Ensure we can shutdown/reboot without needing a password for sudo' do
  sudo append 'ALL   ALL=NOPASSWD:/sbin/shutdown', :to => '/etc/sudoers.d/shutdown'
  sudo append 'ALL   ALL=NOPASSWD:/sbin/reboot', :to => '/etc/sudoers.d/shutdown'
  sudo chmod 440, '/etc/sudoers.d/shutdown'
end

