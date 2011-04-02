module Machines
  module Database
    # Write the database.yml file
    # @param [Hash] options
    # @option options [String] :to Directory to write the database.yml to
    # @option options [String] :for Application name
    def write_database_yml options
      required_options options, [:to, :for]
      app = options[:for]
      yml = {AppConf.environment => {
        'adapter' => 'mysql',
        'database' => app,
        'username' => app,
        'password' => AppConf.apps[app].password,
        'host' => AppConf.database_address,
        'encoding' => 'utf8'}}.to_yaml
      path = File.join(options[:to], 'database.yml')
      Command.new("echo '#{yml}' > #{path}", check_file(path))
    end
  end
end

