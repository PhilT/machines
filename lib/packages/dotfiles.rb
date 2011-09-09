username = AppConf.user.name

task :dotfiles, "Upload files in users/#{username}/dotfiles, prepend a dot and substitute some bashrc vars" do
  Dir["users/#{username}/dotfiles/*"].each do |source|
    run upload source, ".#{File.basename(source)}" if File.exists?(source)
  end

  if File.exists?("users/#{username}/dotfiles/bashrc")
    run replace 'export RAILS_ENV=', :with => "export RAILS_ENV=#{AppConf.environment}", :in => '.bashrc'
    run replace 'export CDPATH=', :with => "export CDPATH=#{AppConf.appsroot}", :in => '.bashrc'
  end
end

authorized_key_file = "users/#{username}/authorized_keys"
if File.exists?(authorized_key_file)
  task :keyfiles, 'Upload authorized_keys file' do
    run mkdir '.ssh'
    run chmod 700, '.ssh'
    run upload authorized_key_file, '.ssh/authorized_keys'
    run chmod 600, '.ssh/authorized_keys'
  end
end

run upload "users/#{username}/Pictures", '$HOME/Pictures' # Pictures/wallpaper.jpg used by openbox autostart.sh

