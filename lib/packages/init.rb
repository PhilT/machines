# Initialization and user input prior to installation

# Settings
AppConf.passwords = []
AppConf.commands = []
AppConf.apps = {}
AppConf.from_hash(:user => {})
AppConf.from_hash(:db => {})
AppConf.load(File.join(AppConf.project_dir, 'config/config.yml'))
AppConf.log_path = File.join(AppConf.project_dir, 'log', 'output.log')
FileUtils.mkdir_p File.dirname(AppConf.log_path)
AppConf.log = File.open(AppConf.log_path, 'w')

# Questions
AppConf.machine = choose_machine
AppConf.ec2.start = start_ec2_instance?
thread = Thread.new { connect && run_instance } if AppConf.ec2.start
AppConf.target_address = enter_target_address('machine') unless AppConf.ec2.start
AppConf.user.name = choose_user
AppConf.user.pass = enter_password('users') unless AppConf.ec2.start
AppConf.user.home = File.join('/home', AppConf.user.name)
AppConf.appsroot = AppConf[AppConf.user.name].appsroot

only :environments => [:staging, :production] do
  AppConf.hostname = AppConf.environment
end

only :environments => :development do
  AppConf.hostname = enter_hostname
end

except :roles => :db do
  AppConf.db.address = enter_target_address('database master machine')
  AppConf.db.pass = enter_password('database root')
end

thread.join
