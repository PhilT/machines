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
      "RUN    gconftool-2 --set \"/apps/docky-2/Docky/Interface/DockPreferences/Dock1/ZoomPercent\" --type float 1.5",
      "RUN    gconftool-2 --set \"/apps/docky-2/Docky/Interface/DockPreferences/Dock1/Autohide\" --type string \"Intellihide\"",
      "RUN    gconftool-2 --set \"/apps/docky-2/Docky/Interface/DockPreferences/Dock1/FadeOnHide\" --type bool true",
      "RUN    gconftool-2 --set \"/apps/docky-2/Docky/Interface/DockPreferences/Dock1/FadeOpacity\" --type float 50.0",
      "RUN    gconftool-2 --set \"/apps/docky-2/Docky/Interface/DockPreferences/Dock1/Launchers\" --type list --list-type=string [\"file:///usr/share/applications/terminator.desktop\",\"file:///usr/share/applications/abiword.desktop\",\"file:///usr/share/applications/gnumeric.desktop\",\"file:///usr/share/applications/firefox.desktop\",\"file:///usr/share/applications/gimp.desktop\",\"file:///usr/share/applications/inkscape.desktop\",\"file:///usr/share/applications/audacious2.desktop\",\"file:///usr/share/applications/gedit.desktop\"]",
      "RUN    gconftool-2 --set \"/apps/docky-2/Docky/Interface/DockPreferences/Dock1/Plugins\" --type list --list-type=string [\"Trash\",\"Clock\",\"GMail\",\"Weather\",\"SessionManager\"]",
      "RUN    gconftool-2 --set \"/schemas/apps/docky-2/Docky/Interface/DockPreferences/Dock1/SortList\" --type list --list-type=string [\"/usr/share/applications/firefox.desktop\",\"TrashCan\",\"Clock\",\"GMailDockItem#Inbox\",\"WeatherDockItem\",\"SessionManager\",\"/usr/share/applications/terminator.desktop\",\"/usr/share/applications/gedit.desktop\",\"/usr/share/applications/abiword.desktop\",\"/usr/share/applications/gnumeric.desktop\",\"/usr/share/applications/gimp.desktop\",\"/usr/share/applications/inkscape.desktop\",\"/usr/share/applications/audacious2.desktop\"]",
      "RUN    gconftool-2 --set \"/apps/docky-2/Clock/ClockDockItem/ShowDate\" --type bool true",
      "RUN    gconftool-2 --set \"/apps/docky-2/Clock/ClockDockItem/ShowDigital\" --type bool true",
      "RUN    gconftool-2 --set \"/apps/docky-2/Clock/ClockDockItem/ShowMilitary\" --type bool true",
      "RUN    gconftool-2 --set \"/apps/docky-2/GMail/GMailPreferences/RefreshRate\" --type int 10",
      "RUN    gconftool-2 --set \"/apps/docky-2/GMail/GMailPreferences/User\" --type string \"phil@example.com\"",
      "RUN    gconftool-2 --set \"/apps/docky-2/WeatherDocklet/WeatherPreferences/Location\" --type list --list-type=string [\"UKXX0085\"]",
      "RUN    gconftool-2 --set \"/apps/docky-2/WeatherDocklet/WeatherPreferences/Metric\" --type bool true"
    ]
  end
end

