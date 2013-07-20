only :user => 'phil' do
  task :workspace, 'Setup home folders' do
    %w(downloads music pictures reference videos).each do |folder|
      run mkdir folder
      run append "file://#{$conf.user_home}/#{folder} folder", to: '.gtk-bookmarks'
    end
  end

  task :extras, 'Install some extra libs, tools, codecs' do
    key = 'ttf-mscorefonts-installer'
    subkey = 'msttcorefonts/accepted-mscorefonts-eula'
    sudo debconf key, subkey, 'select', 'true'

    sudo install [
      'flashplugin-installer',    # Play Flash in a Web browser
      'libsqlite3-dev',           # Needed if SQLite Gem is used
      'ubuntu-restricted-extras', # play/record MP3, DVD, Flash, Quicktime, WMA, WMV, etc
    ]
  end

  task :profile, 'Setup startup, screen lock, misc settings' do
    run append 'startx', :to => '.profile'
    # xlock_cmd = 'xautolock -time 5 -locker slock &'
    # run append xlock_cmd, to: '.xinitrc' if $conf.machine_name == 'phil_laptop'
    # sudo add user: 'phil', to: 'audio'
  end
end
