module Machines
  module Database

    # Run a SQL statement
    # @param [String] sql SQL statement to execute
    # @param [Hash] options
    # @option options [String] :on The host to execute the statement on
    # @option options [String] :password The mysql root password
    def mysql(sql, options)
      required_options options, [:on, :password]
      add "#{sql} | mysql -u root -p#{options[:password]} -h #{options[:on]}"
    end

    # Set a MySQL root password
    # @param [String] password Root password to set
    def mysql_pass password
      add "mysqladmin -u root password #{password}"
    end

    # Write the database.yml file
    # @param [Hash] options
    # @option options [String] :to Directory to write the database.yml to
    # @option options [String] :for Application name
    def write_yaml options
      required_options options, [:to, :for]
      app = options[:for]
      yml = {@environment => {'adapter' => 'mysql', 'database' => app, 'username' => app, 'password' => @passwords[app], 'host' => @dbmaster}}.to_yaml
      add "echo #{yml} > #{File.join(options[:to], 'database.yml')}"
    end
  end
end

