
only :user => 'phil' do
  task :workspace, 'Copies everything from local workspace folder to new machine' do
    run upload '~/workspace', 'workspace'
    run mkdir 'Documents Downloads Music Pictures Videos'
  end

  sudo install [
    'flashplugin-installer',    # Play Flash in a Web browser
    'libsqlite3-dev'            # Needed if SQLite Gem is used
    'ubuntu-restricted-extras', # play/record MP3, DVD, Flash, Quicktime, WMA, WMV, etc
  ]

  run append 'startx', :to => '.profile'
end

