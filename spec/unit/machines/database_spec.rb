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
      AppConf.apps = {'app' => AppBuilder.new(:password => 'password')}
      AppConf.from_hash(:apps => {:app => {:password => 'password'}})

      subject = write_database_yml :for => 'app', :to => 'dir'
      command = subject.command
      command.should match /echo "---.*" > dir\/database.yml/m
      command.should match /test:/m
      command.should match /adapter: mysql/m
      command.should match /database: app/m
      command.should match /username: app/m
      command.should match /password: password/m
      command.should match /host: dbhost/m
    end
  end
end

