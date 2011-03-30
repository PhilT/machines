module Machines
  module Database
    # Run a SQL statement
    # @param [String] sql SQL statement to execute
    # @param [Hash] options
    # @option options [String] :on The host to execute the statement on
    # @option options [String] :password The mysql root password
    def mysql(sql, options)
      required_options options, [:on, :password]
      run "echo \"#{sql}\" | mysql -u root -p#{options[:password]} -h #{options[:on]}", nil
    end

    # Set a MySQL root password
    # @param [String] password Root password to set
    def mysql_pass password
      run "mysqladmin -u root password #{password}", "mysqladmin -u root -p#{password} ping | grep alive #{echo_result}"
    end

    # Write the database.yml file
    # @param [Hash] options
    # @option options [String] :to Directory to write the database.yml to
    # @option options [String] :for Application name
    def write_database_yml options
      required_options options, [:to, :for]
      app = options[:for]
      yml = {@environment.to_s => {'adapter' => 'mysql', 'database' => app, 'username' => app, 'password' => @passwords[app], 'host' => @dbmaster, 'encoding' => 'utf8'}}.to_yaml
      path = File.join(options[:to], 'database.yml')
      run "echo '#{yml}' > #{path}", check_file(path)
    end
  end
end

