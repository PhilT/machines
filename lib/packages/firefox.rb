task :firefox, 'add the Firefox repo and install' do
  sudo add_ppa 'mozillateam/firefox-stable', 'mozilla'
  sudo install %w(firefox)
end

