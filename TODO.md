Need to implement 'uses_delayed_job'
Write database.yml for non development servers
create shared/log folder
setup memcached
force https

EC2 - Look at assigning and freeing elastic IP addresses
  IP addresses need to be temporary for DB servers because:
  * it's more secure if they only have an Amazon private IP address
  * Only 5 IP addresses can be used per region. Additional IPs must be requested from Amazon.

Can more files be ERB templates? Standardise. Need examples (can't remember what they were)
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
DOC: webapps.yml loaded into AppConf
DOC: Adding selfsigned key
EC2 server connections use an SSH key instead of password to connect - How do we set this in machines?
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
Make template more generic
Add CPU monitor to docky

Would set :variable_name, value be better than AppConf.variable = value
Need a better DSL to handle AppConf and also paths File.join is so verbose
  For exmaple, instead of:
    File.join(AppConf.appsroot, 'subfolder')
  How about:
    path :appsroot, 'subfolder'
rvm ruby@gemset --rvmrc to generate passenger compatible .rvmrc

