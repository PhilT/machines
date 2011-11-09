task :save_machines, 'Saves the machines.yml' do
  comments = ''
  File.open('machines.yml') do |f|
    while (line = f.readline) =~ /^#/ do
      comments << line
    end
  end
  File.open( 'machines.yml', 'w') do |f|
    f.puts comments
    f.puts "\n"
    YAML.dump(AppConf.machines, f)
  end
end

