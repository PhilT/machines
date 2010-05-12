def mysql(sql, options = {:on => HOST})
  add "#{sql} | mysql -u root -p#{SQL_ROOT_PASSWORD} -h #{options[:on]}"
end

def mysql_pass password
  add "mysqladmin -u root password #{password}"
end

def write_yaml options
  app = options[:for]
  yml = {RAILS_ENV => {'adapter' => 'mysql', 'database' => app, 'username' => app, 'password' => $passwords[app], 'host' => DBMASTER}}.to_yaml
  add "echo #{yml} > #{File.join(options[:to], 'database.yml')}"
end

