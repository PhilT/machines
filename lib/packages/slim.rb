task :slim, 'Install SLiM desktop manager' do
  sudo install 'slim'
  sudo upload 'slim/themes', '/usr/share/slim/themes'
  sudo replace 'debian-spacefun', :with => AppConf.theme, :in => '/etc/slim.conf'
  sudo link "Pictures/wallpaper.jpg", '/usr/share/slim/themes/custom/background.jpg'
end

