require 'spec_helper'

describe 'packages/dwm' do
  before do
    $conf.appsroot = 'apps_root'
    $conf.dwm = AppConf.new
    $conf.dwm.repo = 'github:dwm:repo'
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   dwm - Download, build and install custom dwm",
      "SUDO   apt-get -q -y install build-essential",
      "SUDO   apt-get -q -y install libx11-dev",
      "SUDO   apt-get -q -y install libxinerama-dev",
      "SUDO   apt-get -q -y install sharutils",
      "RUN    test -d apps_root/dwm && (cd apps_root/dwm && git pull) || git clone --quiet github:dwm:repo apps_root/dwm",
      "SUDO   cd apps_root/dwm && make clean install",
      "TASK   xwindows - Install X, fonts, themes, tools, etc",
      "SUDO   echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula boolean true | debconf-set-selections",
      "SUDO   apt-get -q -y install dmz-cursor-theme",
      "SUDO   apt-get -q -y install elementary-icon-theme",
      "SUDO   apt-get -q -y install feh",
      "SUDO   apt-get -q -y install gnome-screenshot",
      "SUDO   apt-get -q -y install gnome-themes-standard",
      "SUDO   apt-get -q -y install lxappearance",
      "SUDO   apt-get -q -y install pcmanfm",
      "SUDO   apt-get -q -y install rxvt-unicode",
      "SUDO   apt-get -q -y install suckless-tools",
      "SUDO   apt-get -q -y install ttf-ubuntu-font-family",
      "SUDO   apt-get -q -y install ttf-mscorefonts-installer",
      "SUDO   apt-get -q -y install xautolock",
      "SUDO   apt-get -q -y install xorg",
      "SUDO   grep \"inode/directory=pcmanfm.desktop\" .local/share/applications/mimeapps.list || echo \"inode/directory=pcmanfm.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    grep \"startdwm\" ~/.xinitrc || echo \"startdwm\" >> ~/.xinitrc"
    ].join("\n")
  end
end

