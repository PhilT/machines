require 'spec_helper'

describe 'Database' do
  include Machines::Core
  include Machines::Configuration
  include Machines::Database
  include Machines::AppSettings
  include Machines::FileOperations

  describe 'write_database_yml' do
    before do
      alias :run :run_command # alias Machines::Core.run back so it can be called by sudo and the tests etc

      AppConf.environment = 'staging'
      AppConf.db_server = AppConf.new
      AppConf.db_server.address = 'dbhost'
    end

    it 'supplies correct parameters' do
      file = write_database_yml AppBuilder.new(:name => 'app', :password => 'password', :path => 'path')
      file.local.read.must_equal <<-EOF
---
staging:
  adapter: mysql
  database: app
  username: app
  password: password
  host: dbhost
  encoding: utf8
EOF
    end

    it 'writes file to specified path' do
      file = write_database_yml AppBuilder.new(:name => 'app', :password => 'password', :path => 'path')
      file.remote.must_equal 'path/shared/config/database.yml'
    end

    it 'overrides database name when supplied' do
      file = write_database_yml AppBuilder.new(:name => 'app', :password => 'password', :username => 'phil', :database => 'myapp', :path => 'path')
      file.local.read.must_equal <<-EOF
---
staging:
  adapter: mysql
  database: myapp
  username: phil
  password: password
  host: dbhost
  encoding: utf8
EOF
    end
  end
end

