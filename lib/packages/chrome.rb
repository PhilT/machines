task :chrome, 'Add chrome stable repo and installs (set use_opensource to use chromium)' do
  if $conf.use_opensource
    sudo add_ppa 'chromium-daily/stable', 'chromium'
    sudo install 'chromium-browser'
    config_path = '.config/chromium'
  else
    sudo deb 'http://dl.google.com/linux/deb/ stable main',
      key: 'https://dl-ssl.google.com/linux/linux_signing_key.pub',
      name: 'Google'
    sudo install 'google-chrome-stable'
    config_path = '.config/google-chrome'
  end

  run replace '"default_directory": ".*"',
    with: %("default_directory": "#{$conf.chrome.download_path}"),
    in: config_path + '/Default/Preferences'
end
