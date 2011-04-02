# Uploads bashrc, authorized_keys and any specified files if they exist for the user.
# Also sets RAILS_ENV to environment and CDPATH to appsroot for the user (set in users/users.yml)

username = AppConf.user.name
userhome = AppConf.user.home

AppConf.dotfiles.each do |file|
  source = File.join('users', username, file)
  destination = File.join(userhome, ".#{file}")
  run upload source, destination if File.exists?(source)
end

authorized_key_file = File.join('users', username, 'authorized_keys')
if File.exists?(authorized_key_file)
  run mkdir File.join(userhome, '.ssh')
  run chmod 700, File.join(userhome, '.ssh')
  remote_authorized_key_file = File.join(userhome, '.ssh', 'authorized_keys')
  run upload authorized_key_file, remote_authorized_key_file
  run chmod 600, remote_authorized_key_file
end

if File.exists?(File.join('users', username, 'bashrc'))
  run replace 'export RAILS_ENV=', :with => "export RAILS_ENV=#{AppConf.environment}", :in => File.join(userhome, '.bashrc')
  run replace 'export CDPATH=', :with => "export CDPATH=#{AppConf.user.appsroot}", :in => File.join(userhome, '.bashrc')
end

