# Installs mysql, sets app permissions, sets master/slave replication

install %w(libmysqld-dev mysql-server)

mysql_pass AppConf.user.password
restart 'mysql'
apps.each do |app|
  password = development? ? app_config[app][:dev_dir] : passwords[app]
  mysql "GRANT ALL ON *.* TO '#{app}'@'%' IDENTIFIED BY '#{password}';", :on => 'localhost', :password => AppConf.user.password
end

roles :dbmaster do
  upload "mysql/dbmaster.cnf", "/etc/mysql/conf.d/dbmaster.cnf"
  mysql "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY '#{passwords['sql_repl']}';", :on => @host, :password => AppConf.user.password
end

roles :dbslave do
  upload "mysql/dbslave.cnf", "/etc/mysql/conf.d/dbslave.cnf"
  mysql "CHANGE MASTER TO MASTER_HOST='#{@dbmaster}', MASTER_USER='repl' MASTER_PASSWORD='#{passwords['sql_repl']}';", :on => host, :password => AppConf.user.password
end

