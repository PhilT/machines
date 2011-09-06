task :dependencies, 'Dependencies required for various commands to run' do
  sudo update

  sudo install [
    # package                         # Required by command
    # --------------------------------#--------------------
    'debconf-utils',                  # debconf
    'python-software-properties',     # add_ppa
    'gconf2',                         # configure
  ]
end

