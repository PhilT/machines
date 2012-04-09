require 'spec_helper'

describe 'packages/apps' do
  before(:each) do
    load_package('file_roller')
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   file_roller - Install file-roller archive manager",
      "SUDO   apt-get -q -y install file-roller",
      "TASK   file_roller_associations - Setup file associations for file-roller",
      "RUN    echo \"application/x-7z-compressed=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-7z-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-ace=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-alz=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-ar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-arj=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-bzip=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-bzip-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-bzip1=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-bzip1-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-cabinet=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-cbr=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-cbz=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-cd-image=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-compress=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-cpio=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-deb=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-ear=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-ms-dos-executable=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-gtar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-gzip=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-gzpostscript=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-java-archive=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-lha=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-lhz=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-lrzip=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-lrzip-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-lzip=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-lzip-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-lzma=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-lzma-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-lzop=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-lzop-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-rar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-rar-compressed=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-rpm=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-rzip=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-tarz=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-stuffit=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-war=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-xz=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-xz-compressed-tar=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-zip=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-zip-compressed=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-zoo=file-roller.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/zip=file-roller.desktop\" >> .local/share/applications/mimeapps.list"
    ]
  end
end

