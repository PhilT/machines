task :ack, 'Install ack and divert to it' do
  sudo install 'ack-grep'
  sudo 'dpkg-divert --local --divert /usr/bin/ack --rename --add /usr/bin/ack-grep'
end

