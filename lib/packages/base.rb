desc 'set time to zone specified in config.yml and install base packages'

link '/etc/localtime', :to => "/usr/share/zoneinfo/#{Config.time.zone}"
replace 'UTC=yes', :with => 'UTC=no', :in => '/etc/default/rcS'

install %w(build-essential zlib1g-dev libpcre3-dev)
install %w(libreadline5-dev libxml2-dev libxslt1-dev libssl-dev)

