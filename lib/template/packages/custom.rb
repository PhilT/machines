only :user => 'phil' do
  task :workspace, 'Setup home folders' do
    %w(downloads music pictures reference videos).each do |folder|
      run mkdir folder
      run append "file://#{$conf.user_home}/#{folder} folder", to: '.gtk-bookmarks'
    end
  end

  sudo install [
    'flashplugin-installer',    # Play Flash in a Web browser
    'libsqlite3-dev',           # Needed if SQLite Gem is used
    'ubuntu-restricted-extras', # play/record MP3, DVD, Flash, Quicktime, WMA, WMV, etc
  ]

  run append 'startx', :to => '.profile'
end

