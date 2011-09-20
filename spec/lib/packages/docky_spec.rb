require 'spec_helper'

describe 'packages/docky' do
  before(:each) do
    load_package('docky')
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   docky - Install and configure Docky a dock and app launcher",
      "SUDO   apt-get -q -y install docky",
      "SUDO   apt-get -q -y install gnome-system-monitor",
      "RUN    gconftool-2 --set \"/apps/docky-2/Docky/Interface/DockPreferences/FirstRun\" --type bool false",
      "RUN    gconftool-2 --set \"/apps/docky-2/Docky/Interface/DockPreferences/Dock1/ZoomPercent\" --type float 1.5",
      "RUN    gconftool-2 --set \"/apps/docky-2/Docky/Interface/DockPreferences/Dock1/Autohide\" --type string \"Intellihide\"",
      "RUN    gconftool-2 --set \"/apps/docky-2/Docky/Interface/DockPreferences/Dock1/FadeOnHide\" --type bool true",
      "RUN    gconftool-2 --set \"/apps/docky-2/Docky/Interface/DockPreferences/Dock1/FadeOpacity\" --type int 50",
      "RUN    gconftool-2 --set \"/apps/docky-2/Docky/Interface/DockPreferences/Dock1/Launchers\" --type list --list-type=string [\"file:///usr/share/applications/pcmanfm.desktop\",\"file:///usr/share/applications/google-chrome.desktop\",\"file:///usr/share/applications/firefox.desktop\",\"file:///usr/share/applications/terminator.desktop\",\"file:///usr/share/applications/gedit.desktop\",\"file:///usr/share/applications/abiword.desktop\",\"file:///usr/share/applications/gnumeric.desktop\",\"file:///usr/share/applications/gimp.desktop\",\"file:///usr/share/applications/inkscape.desktop\",\"file:///usr/share/applications/audacious2.desktop\"]",
      "RUN    gconftool-2 --set \"/apps/docky-2/Docky/Interface/DockPreferences/Dock1/SortList\" --type list --list-type=string [\"/usr/share/applications/pcmanfm.desktop\",\"/usr/share/applications/google-chrome.desktop\",\"/usr/share/applications/firefox.desktop\",\"/usr/share/applications/terminator.desktop\",\"/usr/share/applications/gedit.desktop\",\"/usr/share/applications/abiword.desktop\",\"/usr/share/applications/gnumeric.desktop\",\"/usr/share/applications/gimp.desktop\",\"/usr/share/applications/inkscape.desktop\",\"/usr/share/applications/audacious2.desktop\"]",
      "RUN    gconftool-2 --set \"/apps/docky-2/Docky/Interface/DockPreferences/Dock1/Plugins\" --type list --list-type=string [\"Trash\",\"Clock\",\"GMail\",\"Weather\"]",
      "RUN    gconftool-2 --set \"/apps/docky-2/Clock/ClockDockItem/ShowDate\" --type bool true",
      "RUN    gconftool-2 --set \"/apps/docky-2/Clock/ClockDockItem/ShowDigital\" --type bool true",
      "RUN    gconftool-2 --set \"/apps/docky-2/Clock/ClockDockItem/ShowMilitary\" --type bool true",
      "RUN    gconftool-2 --set \"/apps/docky-2/GMail/GMailPreferences/RefreshRate\" --type int 10",
      "RUN    gconftool-2 --set \"/apps/docky-2/GMail/GMailPreferences/User\" --type string \"phil@\"",
      "RUN    gconftool-2 --set \"/apps/docky-2/WeatherDocklet/WeatherPreferences/Location\" --type list --list-type=string [\"London\\\\, United Kingdom\"]",
      "RUN    gconftool-2 --set \"/apps/docky-2/WeatherDocklet/WeatherPreferences/Metric\" --type bool true"
    ]
  end
end

