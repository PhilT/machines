class ConfigError < StandardError; end

no_address = "Machine needs to have an address or be an EC2 instance."
no_user = 'No user set for machine.'
no_appsroot = "User does not have an appsroot."

task :questions, 'Ask some questions' do
  AppConf.machine ||= choose_machine
  machine = AppConf.machines[AppConf.machine]
  AppConf.environment = machine['environment'].to_sym if machine['environment']
  AppConf.roles = machine['roles'].map{|role| role.to_sym} if machine['roles']
  AppConf.ec2.use = machine['ec2']
  AppConf.address = machine['address']
  AppConf.user = machine['user']
  AppConf.appsroot = AppConf.appsroots[AppConf.user] if AppConf.user
  AppConf.users = AppConf.appsroots.keys
  AppConf.hostname = machine['hostname']

  errors = []
  errors << no_address unless AppConf.address || AppConf.ec2.use
  errors << no_user unless AppConf.user
  errors << no_appsroot unless AppConf.appsroot || AppConf.user.nil?
  if errors.any?
    errors << 'Check machines.yml and config.yml for errors.'
    raise ConfigError, errors.join("\n")
  end

  thread = Thread.new { connect && run_instance } if AppConf.ec2.use && AppConf.address.nil?

  AppConf.passwords << AppConf.password = 'pa55word' if AppConf.log_only
  AppConf.password ||= enter_password('users', false) unless AppConf.ec2.use

  load_app_settings(machine['apps'])

  only :roles => [:db] do
    AppConf.db.address = 'localhost'
    AppConf.db.replication_pass = AppConf.machines[machine['db']]['replication_pass'] if machine['db']
  end

  except :roles => [:db] do
    if machine['db']
      AppConf.db.address = AppConf.machines[machine['db']]['address']
      AppConf.db.root_pass = AppConf.machines[machine['db']]['root_pass']
    end
  end

  thread.join if thread
end

