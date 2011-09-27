task :slim, 'Install SLiM desktop manager' do
  sudo install 'slim'
  sudo upload 'slim/themes', '/usr/share/slim/themes'
  sudo replace 'debian-spacefun', :with => AppConf.login_theme, :in => '/etc/slim.conf'
end

