task :save_machines, 'Saves the machines.yml' do
  File.open( 'machines.yml', 'w' ) do |f|
    YAML.dump(AppConf.machines, f)
  end
end

