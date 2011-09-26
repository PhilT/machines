task :questions, 'Ask some questions' do
  AppConf.machine ||= choose_machine
  machine = AppConf.machines[AppConf.machine]
  AppConf.environment = AppConf.environments = machine[:environment]
  AppConf.roles = machine[:roles]
  AppConf.users = AppConf.appsroots.keys
  AppConf.ec2.use = machine[:ec2]

  thread = Thread.new { connect && run_instance } if AppConf.ec2.use
  puts AppConf.log_only
  AppConf.host ||= enter_host('machine') unless AppConf.ec2.use || AppConf.log_only
  AppConf.user ||= choose_user

  AppConf.passwords << AppConf.password = 'pa$$word' if AppConf.ec2.use || AppConf.log_only
  AppConf.password ||= enter_password('users', false)
  AppConf.appsroot = AppConf.appsroots[AppConf.user]
  load_app_settings(machine[:apps])

  only :environments => [:staging, :production] do
    AppConf.hostname = AppConf.environment
  end

  only :environment => :development do
    AppConf.hostname = 'hostname' if AppConf.log_only?
    AppConf.hostname ||= enter_hostname
  end

  AppConf.db.address = 'localhost'
  AppConf.db.root_pass = 'password'
  except :roles => [:db] do
    AppConf.db.address = enter_host('database master machine')
    AppConf.db.root_pass = enter_password('database root')
  end

  thread.join if thread
end

