require 'spec_helper'

describe 'packages/apps' do
  before(:each) do
    load_package('apps')
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   apps - Install apps for minimal development machine",
      "SUDO   apt-get -q -y install abiword",
      "SUDO   apt-get -q -y install audacious",
      "SUDO   apt-get -q -y install brasero",
      "SUDO   apt-get -q -y install evince",
      "SUDO   apt-get -q -y install file-roller",
      "SUDO   apt-get -q -y install flashplugin-installer",
      "SUDO   apt-get -q -y install gedit",
      "SUDO   apt-get -q -y install gimp",
      "SUDO   apt-get -q -y install gitk",
      "SUDO   apt-get -q -y install gnumeric",
      "SUDO   apt-get -q -y install inkscape",
      "SUDO   apt-get -q -y install libsqlite3-dev",
      "SUDO   apt-get -q -y install meld",
      "SUDO   apt-get -q -y install mysql-query-browser",
      "SUDO   apt-get -q -y install terminator",
      "SUDO   apt-get -q -y install ubuntu-restricted-extras",
      "SUDO   echo \"text/plain=gedit.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-ruby=gedit.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-shellscript=gedit.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"image/png=gimp.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"image/jpeg=gimp.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"image/svg=inkscape.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/pdf=evince.desktop\" >> .local/share/applications/mimeapps.list",
      "TASK   file_roller_associations - Setup file associations for file-roller",
      "SUDO   echo \"application/x-7z-compressed=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-7z-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-ace=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-alz=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-ar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-arj=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-bzip=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-bzip-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-bzip1=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-bzip1-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-cabinet=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-cbr=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-cbz=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-cd-image=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-compress=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-cpio=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-deb=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-ear=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-ms-dos-executable=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-gtar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-gzip=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-gzpostscript=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-java-archive=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-lha=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-lhz=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-lrzip=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-lrzip-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-lzip=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-lzip-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-lzma=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-lzma-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-lzop=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-lzop-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-rar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-rar-compressed=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-rpm=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-rzip=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-tarz=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-stuffit=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-war=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-xz=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-xz-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-zip=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-zip-compressed=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/x-zoo=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/zip=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "TASK   gnumeric_associations - Setup file associations for Gnumeric",
      "SUDO   echo \"application/x-gnumeric=gnumeric.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet=gnumeric.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"text/csv=gnumeric.desktop\" >> .local/share/applications/mimeapps.list",
      "TASK   abiword_associations - Setup file associations for Abiword",
      "SUDO   echo \"application/x-abiword=abiword.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/msword=abiword.desktop\" >> .local/share/applications/mimeapps.list",
      "SUDO   echo \"application/rtf=abiword.desktop\" >> .local/share/applications/mimeapps.list"
    ]
  end
end

