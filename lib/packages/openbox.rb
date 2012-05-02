task :openbox, 'Install Openbox window manager and associated fonts, themes, etc' do
  sudo debconf 'ttf-mscorefonts-installer', 'msttcorefonts/accepted-mscorefonts-eula', 'boolean', true
  sudo install [
    'dmz-cursor-theme',           # Mouse cursor theme
    'elementary-icon-theme',      # An icon theme
    'feh',                        # Set the background image: feh --bg-scale
    'gnome-screenshot',           # Press Print Screen to take a screen shot of the desktop
    'gnome-themes-standard',      # Needed to theme GTK 3 apps
    'lxappearance',               # Set gtk themes, cursors and icons - Set to clearlooks
    'obconf',                     # Set openbox themes - Set to onyx black
    'openbox',                    # Openbox lightweight Window Manager
    'pcmanfm',                    # Lightweight File manager
    'suckless-tools',             # Includes slock - Locks screen. Password unlocks - no prompt. Can be used with xautolock
    'terminator',                 # Multi-window enhanced console
    'ttf-ubuntu-font-family',     # The new ubuntu font
    'ttf-mscorefonts-installer',  # Microsoft fonts
    'xautolock',                  # Locks screen after idle
    'xcompmgr',                   # Compositing manager - Needed by docky for transparency
    'xorg',                       # Basic X Windows Graphical Interface needed by Openbox
  ]
end

task :fonts, 'Set openbox and Gnome interface fonts (See also rc.xml, fonts.conf, gtkrc-2.0)' do
  run configure "/apps/metacity/general/titlebar_font" => "Ubuntu Bold 8"
  run configure "/apps/nautilus/preferences/desktop_font" => "Ubuntu Light 8"
  run configure "/apps/nautilus/preferences/default_folder_viewer" => 'compact_view'
  run configure "/desktop/gnome/interface/font_name" => "Ubuntu Light 8"
  run configure "/desktop/gnome/interface/document_font_name" => "Ubuntu Light 8"
  run configure "/desktop/gnome/interface/monospace_font_name" => "Monospace 10"
end

sudo append 'inode/directory=pcmanfm.desktop', :to => '.local/share/applications/mimeapps.list'

run append 'ck-launch-session openbox-session', :to => '~/.xinitrc'

