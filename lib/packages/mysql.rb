PASSWORD_CHARS = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a
def random_password
  Array.new(20) { PASSWORD_CHARS[rand(PASSWORD_CHARS.size)] }.join
end

def set_mysql_root_password password
  run "mysqladmin -u root password #{password}", "mysqladmin -u root -p#{password} ping | grep alive #{echo_result}"
end

def mysql_statement(sql, options)
  required_options options, [:on, :password]
  run "echo \"#{sql}\" | mysql -u root -p#{options[:password]} -h #{options[:on]}", nil
end

only :roles => :db do
  task 'Install MySQL' do
    sudo install %w(libmysqld-dev mysql-server)
    set_mysql_root_password AppConf.db.pass
    run restart 'mysql'
  end
end

only :roles => :app do
  task 'Set app permissions' do
    apps.each do |app|
      password = app # password set to app name for development machines
      only :environments => [:staging, :production] do
        password = random_password
      end
      mysql_execute "GRANT ALL ON *.* TO '#{app}'@'%' IDENTIFIED BY '#{password}';",
        :on => AppConf.db.address, :password => AppConf.db.pass
    end
  end
end

task 'Setup database replication' do
  only :roles => :dbmaster do
    sudo upload "mysql/dbmaster.cnf", "/etc/mysql/conf.d/dbmaster.cnf"
    run mysql_statement "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY '#{passwords['sql_repl']}';",
      :on => AppConf.target.address, :password => AppConf.db.pass
  end

  only :roles => :dbslave do
    sudo upload "mysql/dbslave.cnf", "/etc/mysql/conf.d/dbslave.cnf"
    run mysql_statement "CHANGE MASTER TO MASTER_HOST='#{AppConf.dbmaster.address}', MASTER_USER='repl' MASTER_PASSWORD='#{passwords['sql_repl']}';",
      :on => AppConf.target.address, :password => AppConf.db.pass
  end
end

# Need to setup backups on slave

