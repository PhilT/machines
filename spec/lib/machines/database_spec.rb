require 'spec_helper'

describe 'Database' do
  include Core
  include Configuration
  include Database
  include AppSettings

  describe 'write_database_yml' do
    it 'should write the database.yml file' do
      should_receive(:required_options).with({:to => 'dir', :for => 'app'}, [:to, :for])
      AppConf.environment = 'test'
      AppConf.db = AppConf.new
      AppConf.db.address = 'dbhost'
      AppConf.apps = {'app' => AppBuilder.new(:db_password => 'password')}

      yml = "---\ntest:\n  adapter: mysql\n  database: app\n  username: app\n  password: password\n  host: dbhost\n  encoding: utf8\n"
      should_receive(:write).with(yml, :to => 'dir/database.yml', :name => 'database.yml')
      subject = write_database_yml :for => 'app', :to => 'dir'
    end
  end
end

