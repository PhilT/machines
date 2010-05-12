# Helpers for init.d tasks

# Upload _name_ from local init.d folder to /etc/init.d and run update-rc.d
def add_init_d name
  upload "init.d/#{name}", "/etc/init.d/#{name}"
  add "/usr/sbin/update-rc.d -f #{name} defaults"
end

# Restarts _daemon_ using it's init.d script
def restart daemon
  add "/etc/init.d/#{daemon} restart"
end

