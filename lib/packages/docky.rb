task :docky, 'Install and configure Docky a dock and app launcher' do
  sudo install %w(docky) # Panel/Dock launcher

  # Preferences
  run configure '/apps/docky-2/Docky/Interface/DockPreferences/Dock1/ZoomPercent' => 1.5
  run configure '/apps/docky-2/Docky/Interface/DockPreferences/Dock1/Autohide' => 'Intellihide'
  run configure '/apps/docky-2/Docky/Interface/DockPreferences/Dock1/FadeOnHide' =>  true
  run configure '/apps/docky-2/Docky/Interface/DockPreferences/Dock1/FadeOpacity' => 50.0

  # Launchers
  run configure '/apps/docky-2/Docky/Interface/DockPreferences/Dock1/Launchers' =>
    %w(terminator abiword gnumeric firefox gimp inkscape audacious2 gedit).map{|app| "file:///usr/share/applications/#{app}.desktop" }

  run configure '/apps/docky-2/Docky/Interface/DockPreferences/Dock1/Plugins' => %w(Trash Clock GMail Weather SessionManager)

  run configure '/schemas/apps/docky-2/Docky/Interface/DockPreferences/Dock1/SortList' => [
    '/usr/share/applications/firefox.desktop',
    'TrashCan',
    'Clock',
    'GMailDockItem#Inbox',
    'WeatherDockItem',
    'SessionManager',
    '/usr/share/applications/terminator.desktop',
    '/usr/share/applications/gedit.desktop',
    '/usr/share/applications/abiword.desktop',
    '/usr/share/applications/gnumeric.desktop',
    '/usr/share/applications/gimp.desktop',
    '/usr/share/applications/inkscape.desktop',
    '/usr/share/applications/audacious2.desktop'
  ]

  # Clock
  run configure '/apps/docky-2/Clock/ClockDockItem/ShowDate' => true
  run configure '/apps/docky-2/Clock/ClockDockItem/ShowDigital' => true
  run configure '/apps/docky-2/Clock/ClockDockItem/ShowMilitary' => true

  # GMail
  run configure '/apps/docky-2/GMail/GMailPreferences/RefreshRate' => 10
  run configure '/apps/docky-2/GMail/GMailPreferences/User' => "phil@example.com"

  # Weather
  run configure '/apps/docky-2/WeatherDocklet/WeatherPreferences/Location' => ['UKXX0085']
  run configure '/apps/docky-2/WeatherDocklet/WeatherPreferences/Metric' => true
end

