username = AppConf.user.name
userhome = AppConf.user.home

task :dotfiles, "Upload files in users/name/#{username}/dotfiles, prepend a dot and substitute some bashrc vars" do
  dotfiles_dir = File.join(AppConf.project_dir, 'users', username, 'dotfiles')
  Dir[File.join(dotfiles_dir, '*')].each do |source|
    destination = File.join(userhome, ".#{File.basename(source)}")
    run upload source, destination if File.exists?(source)
  end

  if File.exists?(File.join(dotfiles_dir, 'bashrc'))
    run replace 'export RAILS_ENV=', :with => "export RAILS_ENV=#{AppConf.environment}", :in => File.join(userhome, '.bashrc')
    run replace 'export CDPATH=', :with => "export CDPATH=#{AppConf.appsroot}", :in => File.join(userhome, '.bashrc')
  end
end

authorized_key_file = File.join(AppConf.project_dir, 'users', username, 'authorized_keys')
if File.exists?(authorized_key_file)
  task :keyfiles, 'Upload authorized_keys file' do
    run mkdir File.join(userhome, '.ssh')
    run chmod 700, File.join(userhome, '.ssh')
    remote_authorized_key_file = File.join(userhome, '.ssh', 'authorized_keys')
    run upload authorized_key_file, remote_authorized_key_file
    run chmod 600, remote_authorized_key_file
  end
end

run upload File.join(AppConf.project_dir, 'users', 'username', 'Pictures'), '$HOME/Pictures' # Pictures/wallpaper.jpg used by openbox autostart.sh

