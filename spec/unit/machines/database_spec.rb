require 'spec_helper'

describe 'Database' do
  include Machines::Core
  include Machines::Configuration
  include Machines::Database
  include FakeFS::SpecHelpers

  describe 'write_database_yml' do
    it 'should write the database.yml file' do
      should_receive(:required_options).with({:to => 'dir', :for => 'app'}, [:to, :for])
      AppConf.environment = 'test'
      AppConf.database_address = 'dbhost'
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

