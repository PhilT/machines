desc 'Install Passenger'

install libcurl4-openssl-dev

gem 'passenger', :version => AppConf.passenger.version, :as => AppConf.user.name

