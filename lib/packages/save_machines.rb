task :save_machines, 'Saves the machines.yml' do
  File.open( 'machines.yml', 'r+') do |f|
    line = '#'
    while line == '#' do
      line = f.readline
    end
    f.puts ''
    YAML.dump(AppConf.machines, f)
  end
end

