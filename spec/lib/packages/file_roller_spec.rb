require 'spec_helper'

describe 'packages/file_roller' do
  def append_command text
    "RUN    grep \"#{text}\" .local/share/applications/mimeapps.list || echo \"#{text}\" >> .local/share/applications/mimeapps.list"
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   file_roller - Install file-roller archive manager",
      "SUDO   apt-get -q -y install file-roller",
      "TASK   file_roller_assoc - Setup file associations for file-roller",
      append_command('application/x-7z-compressed=file-roller.desktop'),
      append_command('application/x-7z-compressed-tar=file-roller.desktop'),
      append_command('application/x-ace=file-roller.desktop'),
      append_command('application/x-alz=file-roller.desktop'),
      append_command('application/x-ar=file-roller.desktop'),
      append_command('application/x-arj=file-roller.desktop'),
      append_command('application/x-bzip=file-roller.desktop'),
      append_command('application/x-bzip-compressed-tar=file-roller.desktop'),
      append_command('application/x-bzip1=file-roller.desktop'),
      append_command('application/x-bzip1-compressed-tar=file-roller.desktop'),
      append_command('application/x-cabinet=file-roller.desktop'),
      append_command('application/x-cbr=file-roller.desktop'),
      append_command('application/x-cbz=file-roller.desktop'),
      append_command('application/x-cd-image=file-roller.desktop'),
      append_command('application/x-compress=file-roller.desktop'),
      append_command('application/x-compressed-tar=file-roller.desktop'),
      append_command('application/x-cpio=file-roller.desktop'),
      append_command('application/x-deb=file-roller.desktop'),
      append_command('application/x-ear=file-roller.desktop'),
      append_command('application/x-ms-dos-executable=file-roller.desktop'),
      append_command('application/x-gtar=file-roller.desktop'),
      append_command('application/x-gzip=file-roller.desktop'),
      append_command('application/x-gzpostscript=file-roller.desktop'),
      append_command('application/x-java-archive=file-roller.desktop'),
      append_command('application/x-lha=file-roller.desktop'),
      append_command('application/x-lhz=file-roller.desktop'),
      append_command('application/x-lrzip=file-roller.desktop'),
      append_command('application/x-lrzip-compressed-tar=file-roller.desktop'),
      append_command('application/x-lzip=file-roller.desktop'),
      append_command('application/x-lzip-compressed-tar=file-roller.desktop'),
      append_command('application/x-lzma=file-roller.desktop'),
      append_command('application/x-lzma-compressed-tar=file-roller.desktop'),
      append_command('application/x-lzop=file-roller.desktop'),
      append_command('application/x-lzop-compressed-tar=file-roller.desktop'),
      append_command('application/x-rar=file-roller.desktop'),
      append_command('application/x-rar-compressed=file-roller.desktop'),
      append_command('application/x-rpm=file-roller.desktop'),
      append_command('application/x-rzip=file-roller.desktop'),
      append_command('application/x-tar=file-roller.desktop'),
      append_command('application/x-tarz=file-roller.desktop'),
      append_command('application/x-stuffit=file-roller.desktop'),
      append_command('application/x-war=file-roller.desktop'),
      append_command('application/x-xz=file-roller.desktop'),
      append_command('application/x-xz-compressed-tar=file-roller.desktop'),
      append_command('application/x-zip=file-roller.desktop'),
      append_command('application/x-zip-compressed=file-roller.desktop'),
      append_command('application/x-zoo=file-roller.desktop'),
      append_command('application/zip=file-roller.desktop')
    ]
  end
end

