task 'Initialize some AppConf settings' do
  AppConf.passwords = []
  AppConf.commands = []
  AppConf.apps = {}
  AppConf.from_hash(:user => {})
  AppConf.from_hash(:db => {})
  AppConf.load(File.join(AppConf.project_dir, 'config/config.yml'))
  AppConf.log_path = File.join(AppConf.project_dir, 'log', 'output.log')
  FileUtils.mkdir_p File.dirname(AppConf.log_path)
  AppConf.log = File.open(AppConf.log_path, 'w')
end

task 'Ask some questions' do
  AppConf.machine = choose_machine
  AppConf.ec2.use = start_ec2_instance?
  thread = Thread.new { connect && run_instance } if AppConf.ec2.use
  AppConf.target_address = enter_target_address('machine') unless AppConf.ec2.use
  AppConf.users = AppConf.user.name = choose_user
  AppConf.user.pass = enter_password('users') unless AppConf.ec2.use
  AppConf.user.home = File.join('/home', AppConf.user.name)
  AppConf.appsroot = AppConf[AppConf.user.name].appsroot

  only :environments => [:staging, :production] do
    AppConf.hostname = AppConf.environment
  end

  only :environment => :development do
    AppConf.hostname = enter_hostname
  end

  except :roles => :db do
    AppConf.db.address = enter_target_address('database master machine')
    AppConf.db.pass = enter_password('database root')
  end

  thread.join if thread
end

