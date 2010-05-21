require 'spec/spec_helper'

describe 'Database' do

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
    end

  end

  describe 'write_yaml' do
    it 'should write the database.yml file' do
      should_receive(:required_options).with({:to => 'dir', :for => 'app'}, [:to, :for])
      @environment = 'test'
      @dbmaster = 'dbmaster'
      @passwords = {'app' => 'password'}
      write_yaml :for => 'app', :to => 'dir'
      @added.should == ["echo '--- \ntest: \n  username: app\n  adapter: mysql\n  database: app\n  host: dbmaster\n  password: password\n' > dir/database.yml"]
    end
  end
end

