task :productivity, 'Install some productivity apps and set associations'do
  sudo install [
    'audacious',                # media player
    'brasero',                  # CD/DVD Burning tool
    'evince',                   # PDF viewer
    'gimp',                     # bitmap graphics editor
    'gitk',                     # GUI for git
    'inkscape',                 # vector graphics editor
    'meld',                     # Diff tool used by git
    'mysql-navigator',          # GUI for MySQL
  ]

  run append 'application/pdf=evince.desktop', :to => '.local/share/applications/mimeapps.list'
  run append 'image/png=gimp.desktop', :to => '.local/share/applications/mimeapps.list'
  run append 'image/jpeg=gimp.desktop', :to => '.local/share/applications/mimeapps.list'
  run append 'image/svg=inkscape.desktop', :to => '.local/share/applications/mimeapps.list'

end

