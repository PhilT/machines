desc 'Uploads bashrc, gitconfig, vimrc and authorized_keys files if they exist for the user'

username = Config.user.name
userhome = config.user.home

%w(bashrc gitconfig vimrc).each do |file|
  source = File.join('users', username, file)
  destination = File.join(userhome, ".#{file}")
  upload source, destination, :owner => username if File.exists?(source)
end

authorized_key_file = File.join('users', username, 'authorized_keys')
if File.exists?(authorized_key_file)
  mkdir File.join(userhome, '.ssh'), {:perms => '700', :owner => username}
  upload authorized_key_file, File.join(userhome, '.ssh', 'authorized_keys'), {:perms => '600', :owner => username}
end
replace 'export RAILS_ENV=', :with => "export RAILS_ENV=#{environment}", :in => File.join(userhome, '.bashrc')
replace 'export CDPATH=', :with => "export CDPATH=#{Config.apps.root}", :in => File.join(userhome, '.bashrc')

