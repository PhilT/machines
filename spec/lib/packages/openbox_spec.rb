require 'spec_helper'

describe 'packages/openbox' do
  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   openbox - Install Openbox window manager and associated fonts, themes, etc",
      "SUDO   echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula boolean true | debconf-set-selections",
      "SUDO   apt-get -q -y install dmz-cursor-theme",
      "SUDO   apt-get -q -y install elementary-icon-theme",
      "SUDO   apt-get -q -y install feh",
      "SUDO   apt-get -q -y install gnome-screenshot",
      "SUDO   apt-get -q -y install gnome-themes-standard",
      "SUDO   apt-get -q -y install lxappearance",
      "SUDO   apt-get -q -y install obconf",
      "SUDO   apt-get -q -y install openbox",
      "SUDO   apt-get -q -y install pcmanfm",
      "SUDO   apt-get -q -y install suckless-tools",
      "SUDO   apt-get -q -y install terminator",
      "SUDO   apt-get -q -y install ttf-ubuntu-font-family",
      "SUDO   apt-get -q -y install ttf-mscorefonts-installer",
      "SUDO   apt-get -q -y install xautolock",
      "SUDO   apt-get -q -y install xcompmgr",
      "SUDO   apt-get -q -y install xorg",
      "TASK   fonts - Set openbox and Gnome interface fonts (See also rc.xml, fonts.conf, gtkrc-2.0)",
      "RUN    gconftool-2 --set \"/apps/metacity/general/titlebar_font\" --type string \"Ubuntu Bold 8\"",
      "RUN    gconftool-2 --set \"/apps/nautilus/preferences/desktop_font\" --type string \"Ubuntu Light 8\"",
      "RUN    gconftool-2 --set \"/apps/nautilus/preferences/default_folder_viewer\" --type string \"compact_view\"",
      "RUN    gconftool-2 --set \"/desktop/gnome/interface/font_name\" --type string \"Ubuntu Light 8\"",
      "RUN    gconftool-2 --set \"/desktop/gnome/interface/document_font_name\" --type string \"Ubuntu Light 8\"",
      "RUN    gconftool-2 --set \"/desktop/gnome/interface/monospace_font_name\" --type string \"Monospace 10\"",
      "SUDO   grep \"inode/directory=pcmanfm.desktop\" .local/share/applications/mimeapps.list || echo \"inode/directory=pcmanfm.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    grep \"ck-launch-session openbox-session\" ~/.xinitrc || echo \"ck-launch-session openbox-session\" >> ~/.xinitrc"
     ].join("\n")
  end
end

