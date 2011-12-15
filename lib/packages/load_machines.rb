class ConfigError < StandardError; end

task :load_machines, 'Loads the machines.yml' do
  AppConf.machines = AppConf.new
  AppConf.load('machines.yml')

  machine = AppConf.machine = AppConf.machines[AppConf.machine_name]
  raise ConfigError, "#{AppConf.machine_name} does not match any machine in machines.yml" unless machine
  AppConf.db_server = AppConf.machines[machine.db_server]

  machine.root_pass ||= WEBrick::Utils.random_string(20)

  AppConf.user_home = "/home/#{machine.user}"
  AppConf.appsroot = AppConf.appsroots[machine.user] if machine.user
  AppConf.users = AppConf.appsroots.keys
  AppConf.environment = machine.environment
  AppConf.roles = machine.roles

  errors = []
  errors << 'Machine needs to have an address or be an EC2 instance.' unless machine.address || machine.ec2
  errors << 'No user set for machine.' unless machine.user
  errors << 'User does not have an appsroot.' unless AppConf.appsroot || machine.user.nil?
  if errors.any?
    errors << 'Check machines.yml and config.yml for errors.'
    raise ConfigError, errors.join("\n")
  end

  thread = Thread.new { connect && run_instance } if machine.ec2 && machine.address.nil? unless AppConf.log_only

  load_app_settings(machine.apps)

  thread.join if thread
end

