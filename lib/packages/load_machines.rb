class ConfigError < StandardError; end

task :load_machines, 'Loads the machines.yml' do
  $conf.machines = AppConf.new
  $conf.load('machines.yml')

  machine = $conf.machine = $conf.machines[$conf.machine_name]
  raise ConfigError, "#{$conf.machine_name} does not match any machine in machines.yml" unless machine
  $conf.db_server = $conf.machines[machine.db_server]

  if machine.root_pass.nil?
    machine.root_pass = generate_password
    $conf.machines_changed = true
  end

  $conf.user_home = "/home/#{machine.user}"
  $conf.appsroot = $conf.appsroots[machine.user] if machine.user
  $conf.users = $conf.appsroots.keys
  $conf.user = machine.user
  $conf.environment = machine.environment
  $conf.roles = machine.roles

  errors = []
  errors << 'Machine needs to have an address or be an EC2 instance.' unless machine.address || machine.ec2
  errors << 'No user set for machine.' unless machine.user
  errors << 'User does not have an appsroot.' unless $conf.appsroot || machine.user.nil?
  if errors.any?
    errors << 'Check machines.yml and config.yml for errors.'
    raise ConfigError, errors.join("\n")
  end

  thread = Thread.new { connect && run_instance } if machine.ec2 && machine.address.nil? unless $conf.log_only

  load_app_settings(machine.apps)

  thread.join if thread
end

