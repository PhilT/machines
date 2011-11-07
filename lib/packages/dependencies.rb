task :dependencies, 'Dependencies required for various commands to run' do
  sudo update

  sudo install [                      # Needed by
    'debconf-utils',                  # debconf
    'python-software-properties',     # add_ppa
    'gconf2',                         # configure
  ]
end

