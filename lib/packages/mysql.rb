# Installs mysql, sets app permissions, sets master/slave replication

sudo install %w(libmysqld-dev mysql-server)

run mysql_pass AppConf.user.pass
run restart 'mysql'

apps.each do |app|
  password = app
  environments :staging, :production do
    password = 'something'
  end #TODO need to set this to the password created
  run mysql "GRANT ALL ON *.* TO '#{app}'@'%' IDENTIFIED BY '#{password}';", :on => AppConf.dbmaster.address, :password => AppConf.user.pass
end

roles :dbmaster do
  sudo upload "mysql/dbmaster.cnf", "/etc/mysql/conf.d/dbmaster.cnf"
  run mysql "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY '#{passwords['sql_repl']}';",
    :on => AppConf.dbmaster.address, :password => AppConf.user.pass
end

roles :dbslave do
  sudo upload "mysql/dbslave.cnf", "/etc/mysql/conf.d/dbslave.cnf"
  run mysql "CHANGE MASTER TO MASTER_HOST='#{AppConf.dbmaster.address}', MASTER_USER='repl' MASTER_PASSWORD='#{passwords['sql_repl']}';",
    :on => AppConf.host, :password => AppConf.user.pass
end

# Need to setup backups on slave

