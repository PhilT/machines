task :dwm, 'Download, compile and install dwm' do
  sudo install %w(build-essential libx11-dev libxinerama-dev sharutils)

  sudo install "http://dl.suckless.org/dwm/dwm-#{$conf.dwm.version}.tar.gz", make: true
end
