# Installs mysql, sets app permissions, sets master/slave replication

def set_mysql_root_password password
  run "mysqladmin -u root password #{password}", "mysqladmin -u root -p#{password} ping | grep alive #{echo_result}"
end

def mysql_statement(sql, options)
  required_options options, [:on, :password]
  run "echo \"#{sql}\" | mysql -u root -p#{options[:password]} -h #{options[:on]}", nil
end

roles :db do
  sudo install %w(libmysqld-dev mysql-server)
  set_mysql_root_password AppConf.db.pass
  run restart 'mysql'
end

apps.each do |app|
  password = app
  environments :staging, :production do
    password = 'something'
  end #TODO need to set this to the password created
  mysql_execute "GRANT ALL ON *.* TO '#{app}'@'%' IDENTIFIED BY '#{password}';",
    :on => AppConf.dbmaster.address, :password => AppConf.user.pass
end

roles :dbmaster do
  sudo upload "mysql/dbmaster.cnf", "/etc/mysql/conf.d/dbmaster.cnf"
  run mysql_statement "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY '#{passwords['sql_repl']}';",
    :on => AppConf.dbmaster.address, :password => AppConf.user.pass
end

roles :dbslave do
  sudo upload "mysql/dbslave.cnf", "/etc/mysql/conf.d/dbslave.cnf"
  run mysql_statement "CHANGE MASTER TO MASTER_HOST='#{AppConf.dbmaster.address}', MASTER_USER='repl' MASTER_PASSWORD='#{passwords['sql_repl']}';",
    :on => AppConf.host, :password => AppConf.user.pass
end

# Need to setup backups on slave

