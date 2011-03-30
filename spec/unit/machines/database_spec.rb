require 'spec_helper'

describe 'Database' do
  include Machines::Core
  include Machines::Database

  describe 'mysql' do
    it 'should run a SQL statement as root' do
      should_receive(:required_options).with({:on => 'host', :password => 'password'}, [:on, :password])
      mysql 'sql statement', :on => 'host', :password => 'password'
      AppConf.commands.map(&:command).should == ['export TERM=linux && echo "sql statement" | mysql -u root -ppassword -h host']
    end
  end

  describe 'mysql_pass' do
    it 'should set the MySQL root password' do
      mysql_pass 'password'
      AppConf.commands.should == [Command.new('', 'export TERM=linux && mysqladmin -u root password password', "mysqladmin -u root -ppassword ping | grep alive #{echo_result}")]
    end

  end

  describe 'write_database_yml' do
    it 'should write the database.yml file' do
      should_receive(:required_options).with({:to => 'dir', :for => 'app'}, [:to, :for])
      AppConf.environment = 'test'
      AppConf.database_address = 'dbhost'
      AppConf.from_hash(:apps => {:app => {:password => 'password'}})

      write_database_yml :for => 'app', :to => 'dir'
      command = AppConf.commands.first.command
      command.should match /export TERM=linux && echo '---.*' > dir\/database.yml/m
      command.should match /test:/m
      command.should match /adapter: mysql/m
      command.should match /database: app/m
      command.should match /username: app/m
      command.should match /password: password/m
      command.should match /host: dbhost/m
      AppConf.commands.first.check.should == "test -s dir/database.yml #{echo_result}"
    end
  end
end

