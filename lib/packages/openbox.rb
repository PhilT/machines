task :openbox, 'Install Openbox window manager and associated fonts, themes, etc' do
  sudo debconf 'ttf-mscorefonts-installer', 'msttcorefonts/accepted-mscorefonts-eula', 'boolean', true
  sudo install [
    'dmz-cursor-theme',          # Mouse cursor theme
    'elementary-icon-theme',     # An icon theme
    'feh',                       # Set the background image: feh --bg-scale
    'lxappearance',              # Set gtk themes, cursors and icons - Set to clearlooks
    'obconf',                    # Set openbox themes - Set to onyx black
    'openbox',                   # Openbox lightweight Window Manager
    'pcmanfm',                   # Lightweight File manager
    'suckless-tools',            # Installed for slock - Locks screen. Password unlocks - no prompt. Can be used with xautolock
    'ttf-ubuntu-font-family',    # The new ubuntu font
    'ttf-mscorefonts-installer', # Microsoft fonts
    'xautolock',                 # Locks screen after idle
    'xcompmgr',                  # Compositing manager - Needed by docky for transparency
    'xorg',                      # Basic X Windows Graphical Interface needed by Openbox
  ]
end

task :sudo_no_password, 'Ensure we can shutdown/reboot without needing a password for sudo' do
  sudo append 'ALL   ALL=NOPASSWD:/sbin/shutdown', :to => '/etc/sudoers'
  sudo append 'ALL   ALL=NOPASSWD:/sbin/reboot', :to => '/etc/sudoers'
end

task :fonts, 'Set openbox and Gnome interface fonts (See also rc.xml, fonts.conf, gtkrc-2.0)' do
  # NOT NEEDED?
  #configure /desktop/gnome/font_rendering/antialiasing, rgba
  #configure /desktop/gnome/font_rendering/dpi --type float 96
  #configure /desktop/gnome/font_rendering/hinting, slight
  #configure /desktop/gnome/font_rendering/rgba_order, rgb

  run configure "/apps/metacity/general/titlebar_font" => "Ubuntu Bold 8"
  run configure "/apps/nautilus/preferences/desktop_font" => "Ubuntu Light 8"
  run configure "/apps/nautilus/preferences/default_folder_viewer" => 'compact_view'
  run configure "/desktop/gnome/interface/font_name" => "Ubuntu Light 8"
  run configure "/desktop/gnome/interface/document_font_name" => "Ubuntu Light 8"
  run configure "/desktop/gnome/interface/monospace_font_name" => "Monospace 8"
end

