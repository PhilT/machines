task :apps, 'Install apps for minimal development machine' do
  sudo install [
    'abiword',                  # lightweight word processor
    'audacious',                # media player
    'brasero',                  # CD/DVD Burning tool
    'evince',                   # PDF viewer
    'file-roller',              # archive manager
    'flashplugin-installer',    # Play Flash in a Web browser
    'gedit',                    # programmers text editor
    'gimp',                     # bitmap graphics editor
    'gitk',                     # GUI for git
    'gnumeric',                 # lightweight spreadsheet
    'inkscape',                 # vector graphics editor
    'libsqlite3-dev',           # Required for Rails apps that use SQLite database engine
    'meld',                     # Diff tool used by git
    'mysql-query-browser',      # GUI for MySQL
    'terminator',               # enhanced console
    'ubuntu-restricted-extras', # play and record formats, including MP3, DVD, Flash, Quicktime, WMA and WMV
  ]
end

