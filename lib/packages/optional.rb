task :workspace, 'Copies everything from local workspace folder to new machine' do
  run upload '~/workspace', 'workspace'
  run mkdir 'Documents Downloads Music Pictures Videos'
end

