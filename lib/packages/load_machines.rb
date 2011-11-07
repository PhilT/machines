task :load_machines, 'Loads the machines.yml' do
  AppConf.machines = YAML.load(File.open('machines.yml'))
end

