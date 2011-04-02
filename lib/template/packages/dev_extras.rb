# installs flash, ubuntu extras, sqlite3, MS fonts and removes example content
sudo install %w(flashplugin-installer ubuntu-restricted-extras libsqlite3-dev)

sudo install %w(ttf-mscorefonts-installer)
sudo 'fc-cache -f', "fc-cache #{echo_result}"

sudo uninstall %w(example-content)
run remove "#{AppConf.user.home}/examples.desktop"

