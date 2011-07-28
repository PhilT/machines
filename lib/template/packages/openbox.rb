task :openbox, 'Install Openbox window manager and associated fonts, themes, etc' do
  sudo install [
    'dmz-cursor-theme',          # Mouse cursor theme
    'elementary-icon-theme',     # An icon theme
    'feh',                       # Set the background image: feh --bg-scale
    'lxappearance',              # Set gtk themes, cursors and icons - Set to clearlooks
    'obconf',                    # Set openbox themes - Set to onyx black
    'openbox',                   # Openbox lightweight Window Manager
    'pcmanfm',                   # Lightweight File manager
    'slock',                     # Locks screen. Unlocks when users password is entered - no prompt. Can be used with xautolock
    'ttf-ubuntu-font-family',    # The new ubuntu font
    'xautolock',                 # Locks screen after idle
    'xcompmgr',                  # Compositing manager - Needed by docky for transparency
    'xorg',                      # Basic X Windows Graphical Interface needed by Openbox
  ]

  sudo append 'ALL   ALL=NOPASSWD:/sbin/shutdown', :to => '/etc/sudoers'
  sudo append 'ALL   ALL=NOPASSWD:/sbin/reboot', :to => '/etc/sudoers'

  # CHECK IF THESE ARE NEEDED
  #configure /desktop/gnome/font_rendering/antialiasing, rgba
  #configure /desktop/gnome/font_rendering/dpi --type float 96
  #configure /desktop/gnome/font_rendering/hinting, slight
  #configure /desktop/gnome/font_rendering/rgba_order, rgb

  configure "/apps/metacity/general/titlebar_font", "Ubuntu Bold 9"
  configure "/apps/nautilus/preferences/desktop_font", "Ubuntu Light 9"
  configure "/apps/nautilus/preferences/default_folder_viewer", 'compact_view'
  configure "/desktop/gnome/interface/font_name", "Ubuntu Light 9"
  configure "/desktop/gnome/interface/document_font_name", "Ubuntu Light 9"
  configure "/desktop/gnome/interface/monospace_font_name", "Monospace 8"
end

