Setup local velocity server
passenger-install-nginx-module does not seem to be correctly installed from script
point nginx passenger to current/public dickhead!
change monit nginx to use upstart instead of init.d and use risk group
Write database.yml (database.rb) - Change to generic yml writter - pull settings from webapps.yml app environment
rename app.url to server_name
move log files to log/
Add git server to hosts
generate SSH key
permanently add key
check out and build tiny_tds
How can we fix the tiny_tds build to a specific version (e.g. 0.5.0)?
reboot to ensure new connections load rvm
create shared/log folder
setup memcached
Check in riskmachines to scm
setup new scm
No servername in nginx app_server.conf
had to remove error_page 404 and 500 from nginx
force https
chsh -s /bin/bash
machines build MachineName
Add a check to ensure shell is bash
Add docs for each package
All commands and uploads are sent through an ssh connection that is open prior to starting
Commands are generally re-runnable but more effort is probably needed in this area
Handle Net::SSH::HostKeyMismatch errors
Only save machines.yml if it has changed
webapps has gaps in testing (e.g. ssl)
escape $$ in passwords
add condensd as an fork of fountain with some style sheet mods
Remember to parameterize the passenger nginx lines
real ssl certs
Need to ignore hostname server error
webapps
set scm from app.scm
Work on integration tests
setup localhosts to match <webapp>.local
add a package to evmachines to add the extra hosts
add a global section in machines.yml
validate load_machines
Convention: environment.project.domain.com

Would set :variable_name, value be better than AppConf.variable = value
Need a better DSL to handle AppConf and also paths File.join is so verbose
  For exmaple, instead of:
    File.join(AppConf.appsroot, 'subfolder')
  How about:
    path :appsroot, 'subfolder'

Change any references to 'directory' to 'folder'

rvm ruby@gemset --rvmrc to generate passenger compatible .rvmrc

DOC: webapps.yml loaded into AppConf
DOC: Adding selfsigned key

EC2 server connections use an SSH key instead of password to connect - How do we set this in machines?
check replication
wallpaper
gmate appears in ~ and ~/workspace (still not running properly)
need to add git clone keys
cups
additional network interface (/etc/network/interfaces)
git clone projects
e.g. git clone git@github.com:PhilT/mp3tools.git
e.g. git clone phil@server:/media/data/git/amazon_info.git
Pictures scp -r server:/media/data/Pictures ~
Documents
mkdir workspace/public workspace/private workspace/other
A VM for running the machines script! Just need Ruby 1.9.2!
make sure git clone tiny_tds clones the correct version (Wait until 0.5.0 is released)
Keyring asks for a password when using docky Gmail notification
set show hidden and show binary in gedit
MySQL root pass is not set properly
Advice about overwritting template
Favorites don't seem to have been added
Set cron to sensible times /etc/crontab
Look into Fog gem
Set up minimal Ubuntu on EC2
New check - check_command, runs a command and greps response. Replace occurences
Need a way to see optional tasks that are not run as part of full build
Change password to pa$$word in dryrun and replace password in password list
Work on README
Ensure Machines is camelcase throughout docs
Make template more generic
Add CPU monitor to docky
Better error messages

