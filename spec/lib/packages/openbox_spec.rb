require 'spec_helper'

describe 'packages/openbox' do
  before(:each) do
    load_package('openbox')
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   openbox - Install Openbox window manager and associated fonts, themes, etc",
      "SUDO   echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula boolean true | debconf-set-selections",
      "SUDO   apt-get -q -y install dmz-cursor-theme",
      "SUDO   apt-get -q -y install elementary-icon-theme",
      "SUDO   apt-get -q -y install feh",
      "SUDO   apt-get -q -y install lxappearance",
      "SUDO   apt-get -q -y install obconf",
      "SUDO   apt-get -q -y install openbox",
      "SUDO   apt-get -q -y install pcmanfm",
      "SUDO   apt-get -q -y install suckless-tools",
      "SUDO   apt-get -q -y install ttf-ubuntu-font-family",
      "SUDO   apt-get -q -y install ttf-mscorefonts-installer",
      "SUDO   apt-get -q -y install xautolock",
      "SUDO   apt-get -q -y install xcompmgr",
      "SUDO   apt-get -q -y install xorg",
      "TASK   sudo_no_password - Ensure we can shutdown/reboot without needing a password for sudo",
      "SUDO   echo \"ALL   ALL=NOPASSWD:/sbin/shutdown\" >> /etc/sudoers.d/shutdown",
      "SUDO   echo \"ALL   ALL=NOPASSWD:/sbin/reboot\" >> /etc/sudoers.d/shutdown",
      "SUDO   chmod 440 /etc/sudoers.d/shutdown",
      "TASK   fonts - Set openbox and Gnome interface fonts (See also rc.xml, fonts.conf, gtkrc-2.0)",
      "RUN    gconftool-2 --set \"/apps/metacity/general/titlebar_font\" --type string \"Ubuntu Bold 8\"",
      "RUN    gconftool-2 --set \"/apps/nautilus/preferences/desktop_font\" --type string \"Ubuntu Light 8\"",
      "RUN    gconftool-2 --set \"/apps/nautilus/preferences/default_folder_viewer\" --type string \"compact_view\"",
      "RUN    gconftool-2 --set \"/desktop/gnome/interface/font_name\" --type string \"Ubuntu Light 8\"",
      "RUN    gconftool-2 --set \"/desktop/gnome/interface/document_font_name\" --type string \"Ubuntu Light 8\"",
      "RUN    gconftool-2 --set \"/desktop/gnome/interface/monospace_font_name\" --type string \"Monospace 10\"",
      "TASK   usb_policy - Allow users to mount USB drives",
      "UPLOAD config/udisks.policy to /tmp/org.freedesktop.udisks.policy",
      "SUDO   cp -rf /tmp/org.freedesktop.udisks.policy /usr/share/polkit-1/actions/org.freedesktop.udisks.policy",
      "RUN    rm -rf /tmp/org.freedesktop.udisks.policy",
      "SUDO   chmod 644 /usr/share/polkit-1/actions/org.freedesktop.udisks.policy",
      "SUDO   echo \"inode/directory=pcmanfm.desktop\" >> .local/share/applications/mimeapps.list"
     ]
  end
end

