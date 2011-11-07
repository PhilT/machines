class NoHostAddressError < StandardError; end

task :questions, 'Ask some questions' do
  AppConf.machine ||= choose_machine
  machine = AppConf.machines[AppConf.machine]
  AppConf.environment = AppConf.environments = machine['environment']
  AppConf.roles = machine['roles'].map{|role| role.to_sym} if machine['roles']
  AppConf.users = AppConf.appsroots.keys
  AppConf.ec2.use = machine['ec2']

  AppConf.address = machine['address']
  if AppConf.address.nil?
    if AppConf.ec2.use
      thread = Thread.new { connect && run_instance }
    else
      raise NoHostAddressError.new("Machine needs to have an address or be an EC2 instance. Edit machines.yml to correct the issue.")
    end
  end

  AppConf.user = machine[:user]
  AppConf.passwords << AppConf.password = 'pa55word' if AppConf.log_only
  AppConf.password ||= enter_password('users', false) unless AppConf.ec2.use
  AppConf.appsroot = AppConf.appsroots[AppConf.user]
  load_app_settings(machine['apps'])

  AppConf.hostname = machine['hostname']

  only :roles => [:db] do
    AppConf.db.address = 'localhost'
    AppConf.db.replication_pass = AppConf.machines[machine['db']]['replication_pass'] if machine['db']
  end

  except :roles => [:db] do
    AppConf.db.address = AppConf.machines[machine['db']]['address']
    AppConf.db.root_pass = AppConf.machines[machine['db']]['root_pass']
  end

  thread.join if thread
end

