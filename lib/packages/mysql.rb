def set_mysql_root_password password
  run "mysqladmin -u root password #{password}", "mysqladmin -u root -p#{password} ping | grep alive #{echo_result}"
end

def run_mysql_statement(sql, options)
  required_options options, [:on, :password]
  run "echo \"#{sql}\" | mysql -u root -p#{options[:password]} -h #{options[:on]}", nil
end

only :roles => :db do
  task :mysql, 'Install MySQL' do
    sudo install %w(libmysqld-dev mysql-server)
    set_mysql_root_password AppConf.db.pass
    run restart 'mysqld'
  end
end

only :roles => :app do
  task :dbperms, 'Set app permissions to database' do
    AppConf.apps.values.each do |app|
      run_mysql_statement "GRANT ALL ON *.* TO '#{app.name}'@'%' IDENTIFIED BY '#{app.db_password}';",
        :on => AppConf.db.address, :password => AppConf.db.pass
    end
  end
end

only :roles => :dbmaster do
  task :replication, 'Setup database replication' do
    sudo upload "mysql/dbmaster.cnf", "/etc/mysql/conf.d/dbmaster.cnf"
    run_mysql_statement "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY '#{AppConf.database.replication_pass}';",
      :on => AppConf.target.address, :password => AppConf.db.pass
  end
end

only :roles => :dbslave do
  task :replication, 'Setup database replication' do
    sudo upload "mysql/dbslave.cnf", "/etc/mysql/conf.d/dbslave.cnf"
    run_mysql_statement "CHANGE MASTER TO MASTER_HOST='#{AppConf.dbmaster.address}', MASTER_USER='repl' MASTER_PASSWORD='#{AppConf.database.replication_pass}';",
      :on => AppConf.target.address, :password => AppConf.db.pass
  end
end

