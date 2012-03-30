task :save_machines, 'Saves the machines.yml' do
  $conf.save(:machines, 'machines.yml') if $conf.machines_changed
end

