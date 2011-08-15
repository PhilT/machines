require 'spec_helper'

describe 'packages/openbox' do
  before(:each) do
    load_package('openbox')
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "\nTASK   openbox - Install Openbox window manager and associated fonts, themes, etc",
      "SUDO   export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install dmz-cursor-theme",
      "SUDO   apt-get -q -y install elementary-icon-theme",
      "SUDO   apt-get -q -y install feh",
      "SUDO   apt-get -q -y install lxappearance",
      "SUDO   apt-get -q -y install obconf",
      "SUDO   apt-get -q -y install openbox",
      "SUDO   apt-get -q -y install pcmanfm",
      "SUDO   apt-get -q -y install slock",
      "SUDO   apt-get -q -y install ttf-ubuntu-font-family",
      "SUDO   apt-get -q -y install ttf-mscorefonts-installer",
      "SUDO   apt-get -q -y install xautolock",
      "SUDO   apt-get -q -y install xcompmgr",
      "SUDO   apt-get -q -y install xorg",
      "\nTASK   sudo_no_password - Ensure we can shutdown/reboot without needing a password for sudo",
      "SUDO   echo \"ALL   ALL=NOPASSWD:/sbin/shutdown\" >> /etc/sudoers",
      "SUDO   echo \"ALL   ALL=NOPASSWD:/sbin/reboot\" >> /etc/sudoers",
      "\nTASK   fonts - Set openbox and Gnome interface fonts",
      "RUN    gconftool-2 --set \"/apps/metacity/general/titlebar_font\" --type string \"Ubuntu Bold 9\"",
      "RUN    gconftool-2 --set \"/apps/nautilus/preferences/desktop_font\" --type string \"Ubuntu Light 9\"",
      "RUN    gconftool-2 --set \"/apps/nautilus/preferences/default_folder_viewer\" --type string \"compact_view\"",
      "RUN    gconftool-2 --set \"/desktop/gnome/interface/font_name\" --type string \"Ubuntu Light 9\"",
      "RUN    gconftool-2 --set \"/desktop/gnome/interface/document_font_name\" --type string \"Ubuntu Light 9\"",
      "RUN    gconftool-2 --set \"/desktop/gnome/interface/monospace_font_name\" --type string \"Monospace 8\""
    ]
  end
end

