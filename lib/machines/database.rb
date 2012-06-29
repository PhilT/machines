module Machines
  module Database
    # Write the database.yml file from webapps.yml
    # @param [AppBuilder] app
    def write_database_yml app
      yml = {$conf.environment.to_s => {
        'adapter' => 'mysql',
        'database' => app.database || app.name,
        'username' => app.username || app.name,
        'password' => app.password,
        'host' => $conf.db_server.address,
        'encoding' => 'utf8'}}.to_yaml
      write yml, :to => File.join(app.path, 'shared/config/database.yml'), :name => 'database.yml'
    end
  end
end

