task :ntp, 'Install and configure NTP' do
  sudo install 'ntp'
  sudo cp '/etc/ntp.conf', '/etc/ntp.bak'
  sudo upload 'misc/ntp.conf', '/etc/ntp.conf'
end

