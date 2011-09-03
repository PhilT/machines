task :questions, 'Ask some questions' do
  AppConf.machine = choose_machine
  machine = AppConf.machines[AppConf.machine]
  AppConf.environment = AppConf.environments = machine[:environment]
  AppConf.roles = machine[:roles]

  AppConf.ec2.use = start_ec2_instance? unless AppConf.machine == 'Desktop'
  thread = Thread.new { connect && run_instance } if AppConf.ec2.use
  AppConf.target_address = enter_target_address('machine') unless AppConf.ec2.use || AppConf.log_only
  AppConf.user.name = choose_user
  AppConf.user.pass = enter_password('users', false) unless AppConf.ec2.use
  AppConf.user.home = File.join('/home', AppConf.user.name)
  AppConf.appsroot = AppConf.users[AppConf.user.name].appsroot
  load_app_settings(machine[:apps])

  only :environments => [:staging, :production] do
    AppConf.hostname = AppConf.environment
  end

  only :environment => :development do
    AppConf.hostname = enter_hostname
  end

  AppConf.db.address = 'localhost'
  AppConf.db.root_pass = 'password'
  except :roles => [:db] do
    AppConf.db.address = enter_target_address('database master machine')
    AppConf.db.root_pass = enter_password('database root')
  end

  thread.join if thread
end

