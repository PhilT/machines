task :subtle, 'Install Subtle tiling window manager and associated fonts, themes, etc' do
  sudo debconf 'ttf-mscorefonts-installer', 'msttcorefonts/accepted-mscorefonts-eula', 'boolean', true
  sudo install [
    'dmz-cursor-theme',           # Mouse cursor theme
    'elementary-icon-theme',      # An icon theme
    'feh',                        # Set background image/view pics/slideshow/etc
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
    'xorg',                       # Basic X Windows Graphical Interface
  ]

  sudo append 'inode/directory=pcmanfm.desktop', to: '.local/share/applications/mimeapps.list'

  # Copy default subtle.rb file for easy modification
  run mkdir '.local/share/subtle'
  run copy '/etc/xdg/subtle/subtle.rb', '.local/share/subtle'

  run append 'ck-launch-session subtle', to: '~/.xinitrc'
  sudo append 'snd_mixer_oss', to: '/etc/modules'
end
