task :dwm, 'Download, build and install custom dwm' do
  sudo install %w(build-essential libx11-dev libxft-dev libxinerama-dev sharutils)

  dwm_dir = File.join($conf.appsroot, 'dwm')
  run git_clone $conf.dwm.repo, to: dwm_dir
  sudo "cd #{dwm_dir} && make clean install"
end

task :xwindows, 'Install X, fonts, themes, tools, etc' do
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
    'suckless-tools',             # Includes slock - Locks screen. Password unlocks - no prompt. Can be used with xautolock
    'ttf-ubuntu-font-family',     # The new ubuntu font
    'ttf-mscorefonts-installer',  # Microsoft fonts
    'xautolock',                  # Locks screen after idle
    'xorg',                       # Basic X Windows Graphical Interface
  ]

  sudo append 'inode/directory=pcmanfm.desktop', to: '.local/share/applications/mimeapps.list'

  run append 'ck-launch-session dbus-launch startdwm', to: '~/.xinitrc'
end

