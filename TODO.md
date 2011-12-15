EC2 - Look at assigning and freeing elastic IP addresses
  IP addresses need to be temporary for DB servers because:
  * it's more secure if they only have an Amazon private IP address
  * Only 5 IP addresses can be used per region. Additional IPs must be requested from Amazon.


Need to implement 'uses_delayed_job'
Write database.yml for non development servers
create shared/log folder
setup memcached
force https


Simplification
-----------------------------------------------
* Can more files be ERB templates? Standardise. Need examples (can't remember what they were)
* Too many configuration files. How can simplify config.yml, machines.yml, Machinesfile, webapps.yml, questions.rb?
  * It is configuration management afterall but I'm sure we can make it simplier
  * rename questions.rb (package)

Add monit to inittab
generate SSH key for git server
permanently add key for cap to work
Handle Net::SSH::HostKeyMismatch errors
Only save machines.yml if it has changed
webapps has gaps in testing (e.g. ssl)
escape $$ in passwords
turn off debug output by default
real ssl certs
Need to ignore hostname server error (causes check to fail)
set scm from app.scm
add a package to evmachines to add the extra hosts
Need to test ERB templates
Would set :variable_name, value be better than AppConf.variable = value
Need a better DSL to handle AppConf and also paths File.join is so verbose
  For exmaple, instead of:
    File.join(AppConf.appsroot, 'subfolder')
  How about:
    path :appsroot, 'subfolder'

Change any references to 'directory' to 'folder'
had to remove error_page 404 and 500 from nginx

Test nginx start stop scripts. Works locally but not on servers - is custom bit needed? Possibly only for 10.04

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
Ensure Machines is camelcase throughout docs
Make template more generic
Add CPU monitor to docky
Better error messages

