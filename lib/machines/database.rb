module Machines
  module Database
    # Write the database.yml file from webapps.yml
    # @param [Hash] options
    # @option options [String] :to Directory to write the database.yml to
    # @option options [String] :for Application name
    def write_database_yml options
      required_options options, [:to, :for]
      app = options[:for]
      yml = {AppConf.environment.to_s => {
        'adapter' => 'mysql',
        'database' => app,
        'username' => app,
        'password' => AppConf.webapps[app].password,
        'host' => AppConf.db_server.address,
        'encoding' => 'utf8'}}.to_yaml
      write yml, :to => File.join(options[:to], 'database.yml'), :name => 'database.yml'
    end
  end
end

