task :docky, 'Install and configure Docky a dock and app launcher' do
  sudo install 'docky'                  # Panel/Dock launcher
  sudo install 'gnome-system-monitor'   # System info, processes, resources, file system usage

  # Ensure Docky does not try to reset preferences
  run configure '/apps/docky-2/Docky/Interface/DockPreferences/FirstRun' => false

  root = '/apps/docky-2/Docky/Interface/DockPreferences/Dock1'

  # Preferences
  run configure "#{root}/ZoomPercent" => 1.5
  run configure "#{root}/Autohide" => 'Intellihide'
  run configure "#{root}/FadeOnHide" => true
  run configure "#{root}/FadeOpacity" => 50

  # Launchers
  apps = %w(google-chrome firefox terminator gedit abiword gnumeric gimp inkscape audacious2)
  run configure "#{root}/Launchers" => apps.map {|app| "file:///usr/share/applications/#{app}.desktop"}
  run configure "#{root}/SortList" => apps.map {|app| "/usr/share/applications/#{app}.desktop"}

  run configure "#{root}/Plugins" => %w(Trash Clock GMail Weather)

  # Clock
  run configure '/apps/docky-2/Clock/ClockDockItem/ShowDate' => true
  run configure '/apps/docky-2/Clock/ClockDockItem/ShowDigital' => true
  run configure '/apps/docky-2/Clock/ClockDockItem/ShowMilitary' => true

  # GMail
  run configure '/apps/docky-2/GMail/GMailPreferences/RefreshRate' => 10
  run configure '/apps/docky-2/GMail/GMailPreferences/User' => "phil@"

  # Weather
  run configure '/apps/docky-2/WeatherDocklet/WeatherPreferences/Location' => ['London\\, United Kingdom']
  run configure '/apps/docky-2/WeatherDocklet/WeatherPreferences/Metric' => true
end

