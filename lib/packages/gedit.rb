task :gedit, 'Install basic programmers editor and set associations' do
  sudo install [
    'gedit',
  ]

  run append 'text/plain=gedit.desktop', :to => '.local/share/applications/mimeapps.list'
  run append 'application/x-ruby=gedit.desktop', :to => '.local/share/applications/mimeapps.list'
  run append 'application/x-shellscript=gedit.desktop', :to => '.local/share/applications/mimeapps.list'
end

