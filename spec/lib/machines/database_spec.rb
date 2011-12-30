require 'spec_helper'

describe 'Database' do
  include Core
  include Configuration
  include Database
  include AppSettings

  describe 'write_database_yml' do
    before do
      AppConf.environment = 'staging'
      AppConf.db_server = AppConf.new
      AppConf.db_server.address = 'dbhost'
      AppConf.webapps = {'app' => AppBuilder.new(:password => 'password')}
    end

    it 'supplies correct parameters' do
      file = write_database_yml :for => 'app', :to => 'dir'
      file.local.read.should == <<-EOF
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

    it 'overrides database name when supplied' do
      AppConf.webapps = {'app' => AppBuilder.new(:password => 'password', :username => 'phil', :database => 'myapp')}
      file = write_database_yml :for => 'app', :to => 'dir'
      file.local.read.should == <<-EOF
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

