task :apps, 'Apps for dev minimal machine' do
  sudo install [
    'abiword',            # 'a lightweight word processor'
    'audacious',          # 'a media player'
    'brasero',            # 'a CD/DVD Burning tool'
    'file-roller',        # 'an archive manager'
    'evince',             # 'a PDF viewer'
    'gedit',              # 'a programmers text editor'
    'gimp',               # 'a bitmap graphics editor'
    'gnumeric',           # 'a lightweight spreadsheet'
    'inkscape',           # 'a vector graphics editor'
    'terminator',         # 'an enhanced console'
    'usb-creator-gtk',    # 'a USB boot disk creator'
  ]
end

