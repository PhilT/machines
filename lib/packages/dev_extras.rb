desc 'installs flash, ubuntu extras, sqlite3, MS fonts and removes example content'
install %w(flashplugin-installer ubuntu-restricted-extras libsqlite3-dev)

install %w(ttf-mscorefonts-installer)
run 'fc-cache -f', "fc-cache #{pass_fail}"

uninstall %w(example-content)
remove "#{Config.user.home}/examples.desktop", :force => true
