# installs
#   * flash
#   * ubuntu extras
#   * sqlite3
#   * MS fonts
#   * VirtualBox
# removes
#   * example content

sudo install %w(flashplugin-installer ubuntu-restricted-extras libsqlite3-dev)

sudo install %w(ttf-mscorefonts-installer)
sudo 'fc-cache -f', "fc-cache #{echo_result}"

sudo uninstall %w(example-content)
run remove "#{AppConf.user.home}/examples.desktop"

sudo install 'dkms' # Ensure kernal modules are updated when upgrading virtual box
sudo deb 'http://download.virtualbox.org/virtualbox/debian DISTRIB_CODENAME contrib non-free',
  :key => 'http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc',
  :name => 'VirtualBox'
sudo update

sudo install 'virtualbox-4.0'

