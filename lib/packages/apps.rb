task :apps, 'Install apps for minimal development machine' do
  sudo install [
    'abiword',                  # lightweight word processor
    'audacious',                # media player
    'brasero',                  # CD/DVD Burning tool
    'evince',                   # PDF viewer
    'file-roller',              # archive manager
    'flashplugin-installer',    # Play Flash in a Web browser
    'gedit',                    # programmers text editor
    'gimp',                     # bitmap graphics editor
    'gitk',                     # GUI for git
    'gnumeric',                 # lightweight spreadsheet
    'inkscape',                 # vector graphics editor
    'libsqlite3-dev',           # Required for Rails apps that use SQLite database engine
    'meld',                     # Diff tool used by git
    'mysql-query-browser',      # GUI for MySQL
    'terminator',               # enhanced console
    'ubuntu-restricted-extras', # play and record formats, including MP3, DVD, Flash, Quicktime, WMA and WMV
  ]

  sudo append 'text/plain=gedit.desktop', :to => '.local/share/applications/mimeapps.list'
  sudo append 'application/x-ruby=gedit.desktop', :to => '.local/share/applications/mimeapps.list'
  sudo append 'application/x-shellscript=gedit.desktop', :to => '.local/share/applications/mimeapps.list'
  sudo append 'image/png=gimp.desktop', :to => '.local/share/applications/mimeapps.list'
  sudo append 'image/jpeg=gimp.desktop', :to => '.local/share/applications/mimeapps.list'
  sudo append 'image/svg=inkscape.desktop', :to => '.local/share/applications/mimeapps.list'
end

task :file_roller_associations, 'Setup file associations for file-roller' do
  mimetypes = 'application/x-7z-compressed;application/x-7z-compressed-tar;application/x-ace;application/x-alz;application/x-ar;application/x-arj;application/x-bzip;application/x-bzip-compressed-tar;application/x-bzip1;application/x-bzip1-compressed-tar;application/x-cabinet;application/x-cbr;application/x-cbz;application/x-cd-image;application/x-compress;application/x-compressed-tar;application/x-cpio;application/x-deb;application/x-ear;application/x-ms-dos-executable;application/x-gtar;application/x-gzip;application/x-gzpostscript;application/x-java-archive;application/x-lha;application/x-lhz;application/x-lrzip;application/x-lrzip-compressed-tar;application/x-lzip;application/x-lzip-compressed-tar;application/x-lzma;application/x-lzma-compressed-tar;application/x-lzop;application/x-lzop-compressed-tar;application/x-rar;application/x-rar-compressed;application/x-rpm;application/x-rzip;application/x-tar;application/x-tarz;application/x-stuffit;application/x-war;application/x-xz;application/x-xz-compressed-tar;application/x-zip;application/x-zip-compressed;application/x-zoo;application/zip;'
  mimetypes.split(';').each do |mimetype|
    sudo append "#{mimetype}=file-roller.desktop", :to => '.local/share/applications/mimeapps.list'
  end
end

task :gnumeric_associations, 'Setup file associations for Gnumeric' do
  mimetypes = 'application/x-gnumeric;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;text/csv'
  mimetypes.split(';').each do |mimetype|
    sudo append "#{mimetype}=gnumeric.desktop", :to => '.local/share/applications/mimeapps.list'
  end
end

task :abiword_associations, 'Setup file associations for Abiword' do
  mimetypes = 'application/x-abiword;application/msword;application/rtf;'
  mimetypes.split(';').each do |mimetype|
    sudo append "#{mimetype}=abiword.desktop", :to => '.local/share/applications/mimeapps.list'
  end
end

task :evince_associations, 'Setup file associations for Evince' do
  mimetypes = 'application/pdf;application/x-bzpdf;application/x-gzpdf;application/postscript;application/x-bzpostscript;application/x-gzpostscript;image/x-eps;image/x-bzeps;image/x-gzeps;application/x-dvi;application/x-bzdvi;application/x-gzdvi;image/vnd.djvu;image/tiff;application/x-cbr;application/x-cbz;application/x-cb7;application/x-cbt;image/*;application/vnd.sun.xml.impress;application/vnd.oasis.opendocument.presentation;'
  mimetypes.split(';').each do |mimetype|
    sudo append "#{mimetype}=evince.desktop", :to => '.local/share/applications/mimeapps.list'
  end
end

