task :workspace, 'Copies everything from local workspace folder to new machine' do
  run upload '~/workspace', '~/workspace'
end

