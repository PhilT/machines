task :sqlserver, 'Download and build sqlserver driver' do
  run git_clone 'git://github.com/rails-sqlserver/tiny_tds.git'
  run 'cd tiny_tds && rake compile && rake native gem', check_file('tiny_tds/pkg/tiny_tds-0.5.0-amd64-linux.gem')
end

