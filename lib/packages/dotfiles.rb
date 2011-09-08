username = AppConf.user.name
userhome = AppConf.user.home

task :dotfiles, "Upload files in users/name/#{username}/dotfiles, prepend a dot and substitute some bashrc vars" do
  Dir["users/#{username}/dotfiles/*"].each do |source|
    destination = File.join(userhome, ".#{File.basename(source)}")
    run upload source, destination if File.exists?(source)
  end

  if File.exists?("users/#{username}/dotfiles/bashrc")
    run replace 'export RAILS_ENV=', :with => "export RAILS_ENV=#{AppConf.environment}", :in => File.join(userhome, '.bashrc')
    run replace 'export CDPATH=', :with => "export CDPATH=#{AppConf.appsroot}", :in => File.join(userhome, '.bashrc')
  end
end

authorized_key_file = "users/#{username}/authorized_keys"
if File.exists?(authorized_key_file)
  task :keyfiles, 'Upload authorized_keys file' do
    run mkdir File.join(userhome, '.ssh')
    run chmod 700, File.join(userhome, '.ssh')
    remote_authorized_key_file = File.join(userhome, '.ssh', 'authorized_keys')
    run upload authorized_key_file, remote_authorized_key_file
    run chmod 600, remote_authorized_key_file
  end
end

run upload "users/#{username}/Pictures", '$HOME/Pictures' # Pictures/wallpaper.jpg used by openbox autostart.sh

