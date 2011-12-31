Allow AppConf.webapps[app].path to be overridden from webapps.yml
?? Does webapps.yml structure get preserved? (e.g. when modifying keys and resaving)
Fix guard notifications

Enable YAML to refer to other settings in the same file
development machines should clone repos
force https

EC2 - Look at assigning and freeing elastic IP addresses
  IP addresses need to be temporary for DB servers because:
  * it's more secure if they only have an Amazon private IP address
  * Only 5 IP addresses can be used per region. Additional IPs must be requested from Amazon.
  * Maybe use Fog to use any supported cloud service
  * machines.machine.address = an elastic IP address
  * machnies.machine.ec2.instance_id = the ec2 address
  * An elastic IP address must be set up when running machines (unless it's run in the cloud!)
  * Set AppConf.machines_changed when creating a new instance
  * EC2 server connections use an SSH key instead of password to connect - How do we set this in machines?
  * Set up minimal Ubuntu on EC2

Should be able to run Passenger install easily for new versions
Can more files be ERB templates? Standardise. Need examples (can't remember what they were)
Add monit to inittab [SERVER]
Handle Net::SSH::HostKeyMismatch errors (need to delete existing key)
webapps has gaps in testing (e.g. ssl)
escape $$ in passwords
turn off debug output by default
real ssl certs
Need to ignore hostname server error (causes check to fail)
add a package to evmachines to add the extra hosts
Need to test ERB templates
DOC: webapps.yml loaded into AppConf
DOC: Adding selfsigned key
Keyring asks for a password when using docky Gmail notification [DEV]
set show hidden and show binary in gedit [DEV]
MySQL root pass is not set properly
Recommended practice for overwritting project with new template. Use Git
Set cron to sensible times /etc/crontab [DEV]
New check - check_command, runs a command and greps response. Replace occurences
Need a way to see optional tasks that are not run as part of full build
Make template more generic
Add CPU monitor to docky [DEV]

Would `set :variable_name, value` be better than `AppConf.variable = value`?
Need a better DSL to handle AppConf and also paths File.join is so verbose
  For exmaple, instead of:
    File.join(AppConf.appsroot, 'subfolder')
  How about:
    path :appsroot, 'subfolder'
rvm ruby@gemset --rvmrc to generate passenger compatible .rvmrc
setup memcached
passenger_nginx was installed with rvmsudo. Need to test it still works with just sudo

