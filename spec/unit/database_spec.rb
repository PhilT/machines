require 'spec_helper'

describe 'Database' do
  include Machines::Database
  include FakeAddHelper

  describe 'mysql' do
    it 'should run a SQL statement as root' do
      should_receive(:required_options).with({:on => 'host', :password => 'password'}, [:on, :password])
      mysql 'sql statement', :on => 'host', :password => 'password'
      @added.should == ['echo "sql statement" | mysql -u root -ppassword -h host']
    end
  end

  describe 'mysql_pass' do
    it 'should set the MySQL root password' do
      mysql_pass 'password'
      @added.should == ['mysqladmin -u root password password']
      @checks.should == ["mysqladmin -u root -ppassword ping | grep alive #{pass_fail}"]
    end

  end

  describe 'write_yaml' do
    it 'should write the database.yml file' do
      should_receive(:required_options).with({:to => 'dir', :for => 'app'}, [:to, :for])
      @environment = 'test'
      @dbmaster = 'dbmaster'
      @passwords = {'app' => 'password'}
      write_yaml :for => 'app', :to => 'dir'
      actual = @added.first
      actual.should match /echo '.*' > dir\/database.yml/m
      actual.should match /test:/m
      actual.should match /adapter: mysql/m
      actual.should match /database: app/m
      actual.should match /host: dbmaster/m
      actual.should match /password: password/m
      actual.should match /username: app/m
      @checks.should == ["test -s dir/database.yml #{pass_fail}"]
    end
  end
end

