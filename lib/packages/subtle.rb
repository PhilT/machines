task :subtle, 'Install Subtle tiling window manager and associated fonts, themes, etc' do
  sudo debconf 'ttf-mscorefonts-installer', 'msttcorefonts/accepted-mscorefonts-eula', 'boolean', true
  sudo install [
    'dmz-cursor-theme',           # Mouse cursor theme
    'elementary-icon-theme',      # An icon theme
    'feh',                        # Set the background image: feh --bg-scale
    'gnome-screenshot',           # Press Print Screen to take a screen shot of the desktop
    'gnome-themes-standard',      # Needed to theme GTK 3 apps
    'lxappearance',               # Set gtk themes, cursors and icons - Set to clearlooks
    'pcmanfm',                    # Lightweight File manager
    'rxvt-unicode',               # Default Subtle console
    'subtle',                     # Tiling window manager
    'suckless-tools',             # Includes slock - Locks screen. Password unlocks - no prompt. Can be used with xautolock
    'ttf-ubuntu-font-family',     # The new ubuntu font
    'ttf-mscorefonts-installer',  # Microsoft fonts
    'xautolock',                  # Locks screen after idle
    'xorg',                       # Basic X Windows Graphical Interface needed by Openbox
  ]
end

sudo append 'inode/directory=pcmanfm.desktop', :to => '.local/share/applications/mimeapps.list'

