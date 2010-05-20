module Machines
  module Database

    # Run a SQL statement
    # @param [String] sql SQL statement to execute
    # @param [Hash] options
    # @option options [String] :on The host to execute the statement on
    # @option options [String] :password The mysql root password
    def mysql(sql, options)
      required_options options, [:on, :password]
      add "echo \"#{sql}\" | mysql -u root -p#{options[:password]} -h #{options[:on]}", nil
    end

    # Set a MySQL root password
    # @param [String] password Root password to set
    def mysql_pass password
      add "mysqladmin -u root password #{password}", nil
    end

    # Write the database.yml file
    # @param [Hash] options
    # @option options [String] :to Directory to write the database.yml to
    # @option options [String] :for Application name
    def write_yaml options
      required_options options, [:to, :for]
      app = options[:for]
      yml = {@environment => {'adapter' => 'mysql', 'database' => app, 'username' => app, 'password' => @passwords[app], 'host' => @dbmaster}}.to_yaml
      path = File.join(options[:to], 'database.yml')
      add "echo '#{yml}' > #{path}", check_file(path)
    end
  end
end

