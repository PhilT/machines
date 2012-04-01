def mysql_execute(sql, options)
  required_options options, [:password]
  run "echo \"#{sql}\" | mysql -u root -p#{options[:password]}", nil
end

only :roles => :db do
  task :mysql, 'Install MySQL' do
    name = 'mysql-server-5.1'
    key = 'mysql-server/root_password'
    sudo debconf name, key, 'password', $conf.machine.root_pass
    sudo debconf name, "#{key}_again", 'password', $conf.machine.root_pass
    sudo install %w(mysql-server libmysqlclient-dev)
    run restart 'mysqld'
  end
end

only :roles => :dbmaster do
  task :dbperms, 'Grant applications access to the database' do
    $conf.webapps.values.each do |app|
      mysql_execute "GRANT ALL ON *.* TO '#{app.name}'@'%' " +
        "IDENTIFIED BY '#{app.password}';",
        :password => $conf.machine.root_pass
    end
  end

  task :replication, 'Grant replication access to this machine' do
    sudo upload "mysql/dbmaster.cnf", "/etc/mysql/conf.d/dbmaster.cnf"
    mysql_execute "GRANT REPLICATION SLAVE ON *.* " +
      "TO '#{$conf.machine.replication_user}'@'%' " +
      "IDENTIFIED BY '#{$conf.machine.replication_pass}';",
      :password => $conf.machine.root_pass
  end
end

only :roles => :dbslave do
  task :replication, 'Setup database replication from master' do
    sudo upload "mysql/dbslave.cnf", "/etc/mysql/conf.d/dbslave.cnf"
    mysql_execute "CHANGE MASTER TO " +
      "MASTER_HOST='#{$conf.db_server.address}', " +
      "MASTER_USER='#{$conf.db_server.replication_user}' " +
      "MASTER_PASSWORD='#{$conf.db_server.replication_pass}';",
    :password => $conf.machine.root_pass
  end
end

task :monit_mysql, 'Configure monit for MySQL', :if => [:monit, :mysql] do
  sudo create_from 'monit/conf.d/mysql.erb', :to => '/etc/monit/conf.d/mysql'
end

