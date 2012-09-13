TODO next
----------------------------------------

Support missing environment (e.g. source repo machine)
`machines dryrun/build` with no machine name should list the machines available
DRY up per user config by creating a "common" user config that all users pull default config from
DRY up further by having default templates in the same way that packages default to built-in ones
  (In other words remove as much as possible from evmachines)
Complement this by providing a command to view packages and templates
Move dotfiles to a repo so they can be managed across projects
Handle apt-get error 110 and retry
Move packages into a separate gem
Move template into a separate gem


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

Package and Task Tasks
----------------------------------------

Support running multiple tasks - e.g. `machines build passenger passenger_nginx nginx`
Any methods other than `append` that cannot be repeatedly run?
Display additional install notes for a particular package (at the end of installation) - e.g. printer setup requires Windows share to be setup
CODE/DOC: Describe difference between package and task or merge packages with tasks if possible
BUG: Report error if task is nested
?? Define packages as a group of tasks?


Misc Tasks
----------------------------------------

Remove percentage from progress once command has completed
DOC: How webapps environment specific settings override default settings and how to set your own
DOC: All config files
DOC: Why we use ~/.profile (with links)
On initial SSH connection to machine, test we have an Internet connection. Fail if not.
Add the check that was run to `CHECK_FAILED/CHECK_PASSED`
Output progress to log/<machine_name>_progress.log
Rename output log to log/<machine_name>_output.log
DOC: machines desc <package> - Should display a detailed description of the package
machines list - Display a list of machines to build (or maybe machines build/dryrun with no machinename)
?? base package may not be needed on DB installs
?? Default path for Nginx install is /usr/local - Is it installed correctly for non-default paths?
?? I have a new webapp - How can I add it to a server that has already been installed?
BUG: Uploads throw exception if local file is missing - Get upload to check file existence when adding to queue
BUG: CTRL+C doesn't quite exit cleanly
Check $conf.db_server is picked up and used to write database.yml on qa/staging/production

Allow $conf.webapps[app].path to be overridden from webapps.yml
?? Does webapps.yml structure get preserved? (e.g. when modifying keys and resaving)
Fix guard notifications

Enable YAML to refer to other settings in the same file
development machines should clone repos

Should be able to run Passenger install easily for new versions
Can more files be ERB templates? Standardise. Need examples (can't remember what they were)
webapps has gaps in testing (e.g. ssl)
escape $$ in passwords
turn off debug output by default
DOC: webapps.yml loaded into $conf
MySQL root pass is not set properly
Recommended practice for overwritting project with new template. Use Git
Set cron to sensible times /etc/crontab [DEV]
Need a way to see optional tasks that are not run as part of full build

Would `set :variable_name, value` be better than `$conf.variable = value`?
Need a better DSL to handle $conf and also paths File.join is so verbose
  For exmaple, instead of:
    File.join($conf.appsroot, 'subfolder')
  How about:
    path :appsroot, 'subfolder'
rvm ruby@gemset --rvmrc to generate passenger compatible .rvmrc
setup memcached
passenger_nginx was installed with rvmsudo. Need to test it still works with just sudo

