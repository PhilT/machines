task :load_machines, 'Loads the machines.yml' do
  AppConf.machines = YAML.load_file('machines.yml')
end

