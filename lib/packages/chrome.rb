sudo deb 'http://dl.google.com/linux/deb/ stable main',
  :key => 'https://dl-ssl.google.com/linux/linux_signing_key.pub',
  :name => 'Google'
sudo update

sudo install 'google-chrome-stable'

