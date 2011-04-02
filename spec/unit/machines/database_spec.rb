require 'spec_helper'

describe 'Database' do
  include Machines::Core
  include Machines::Database
  include FakeFS::SpecHelpers

  describe 'mysql' do
    before { should_receive(:required_options).with({:on => 'host', :password => 'password'}, [:on, :password]) }
    subject { subject = mysql 'sql statement', :on => 'host', :password => 'password' }
    it { subject.command.should == 'echo "sql statement" | mysql -u root -ppassword -h host' }
  end

  describe 'mysql_pass' do
    subject { mysql_pass 'password' }
    it { subject.command.should == 'mysqladmin -u root password password' }
    it { subject.check.should == "mysqladmin -u root -ppassword ping | grep alive #{echo_result}" }
  end

  describe 'write_database_yml' do
    it 'should write the database.yml file' do
      should_receive(:required_options).with({:to => 'dir', :for => 'app'}, [:to, :for])
      AppConf.environment = 'test'
      AppConf.database_address = 'dbhost'
      AppConf.from_hash(:apps => {:app => {:password => 'password'}})

      subject = write_database_yml :for => 'app', :to => 'dir'
      command = subject.command
      command.should match /echo '---.*' > dir\/database.yml/m
      command.should match /test:/m
      command.should match /adapter: mysql/m
      command.should match /database: app/m
      command.should match /username: app/m
      command.should match /password: password/m
      command.should match /host: dbhost/m
      subject.check.should == "test -s dir/database.yml #{echo_result}"
    end
  end
end

