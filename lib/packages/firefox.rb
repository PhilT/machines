task 'add the Firefox repo and install' do
  sudo add_ppa 'mozillateam/firefox-stable', 'mozilla'
  sudo update
  sudo install %w(firefox)
end

