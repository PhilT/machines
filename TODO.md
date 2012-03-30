WHAT IS MY FOCUS?
----------------------------------------
* Look at commandline_spec
* Get existing test working (stop writing additional code and park it)
* Get machines running with MiniSpec
* Run a machines install on a VM
* Should I add source bashrc?

Cloud
----------------------------------------
Use EC2 IP address for connecting to database servers
Create elastic IP address for web servers

* Assign private/public keys
* Create security groups - check they exist and modify or create as required
  Use roles to assign security groups
  * everything gets the ssh group (open port 22)
  * app role gets the web group (open port 80, 443)


EC2 - Look at assigning and freeing elastic IP addresses

  * machines.machine.address = an elastic IP address
  * machnies.machine.ec2.instance_id = the ec2 id
  * Set $conf.machines_changed when creating a new instance
  * Set up minimal Ubuntu on EC2
  * Must allow multiple dev machines to access cloud (so multiple SSH keys must be assigned)

Misc Tasks
----------------------------------------

Allow $conf.webapps[app].path to be overridden from webapps.yml
?? Does webapps.yml structure get preserved? (e.g. when modifying keys and resaving)
Fix guard notifications

Enable YAML to refer to other settings in the same file
development machines should clone repos
force https

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
DOC: webapps.yml loaded into $conf
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

Would `set :variable_name, value` be better than `$conf.variable = value`?
Need a better DSL to handle $conf and also paths File.join is so verbose
  For exmaple, instead of:
    File.join($conf.appsroot, 'subfolder')
  How about:
    path :appsroot, 'subfolder'
rvm ruby@gemset --rvmrc to generate passenger compatible .rvmrc
setup memcached
passenger_nginx was installed with rvmsudo. Need to test it still works with just sudo

