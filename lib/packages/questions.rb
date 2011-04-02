# Ask setup questions prior to installation and configuration

AppConf.machine = choose_machine
AppConf.ec2_instance = start_ec2_instance?
Thread.new { start_ec2_instance } if AppConf.ec2_instance
unless AppConf.ec2_instance
  AppConf.target_address = enter_target_address('machine')
  AppConf.user.name = choose_user
  AppConf.user.pass = enter_password('users')
end

only :environments => [:staging, :production] do
  AppConf.hostname = AppConf.environment
end

only :environments => :development
  AppConf.hostname = enter_hostname
end

except :roles => :db
  AppConf.db.address = enter_target_address('database master machine')
  AppConf.db.pass = enter_password('database root')
end

