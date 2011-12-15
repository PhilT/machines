task :save_machines, 'Saves the machines.yml' do
  AppConf.save(:machines, 'machines.yml')
end

