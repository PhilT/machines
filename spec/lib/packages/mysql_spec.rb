require 'spec_helper'

describe 'packages/mysql' do
  before(:each) do
    load_package('mysql')
    AppConf.from_hash(:db => {:address => 'DBIP', :root_pass => 'DBPASS', :replication_pass => 'REPL_PASS'})
    AppConf.from_hash(:target => {:address => 'TARGET'})
    AppConf.from_hash(:dbmaster => {:address => 'DBMASTER'})
    @time = Time.now
    Time.stub(:now).and_return @time
  end

  context 'db role' do
    it 'installs MySQL' do
      AppConf.roles = :db

      eval_package
      AppConf.commands.map(&:info).should == [
        "TASK   mysql - Install MySQL",
        "SUDO   export DEBIAN_FRONTEND=noninteractive && apt-get -q -y install debconf-utils",
        "SUDO   echo mysql-server-5.1 mysql-server/root_password password DBPASS | debconf-set-selections",
        "SUDO   echo mysql-server-5.1 mysql-server/root_password_again password DBPASS | debconf-set-selections",
        "SUDO   apt-get -q -y install mysql-server",
        "RUN    service mysqld restart"
      ]
    end
  end

  context 'app role' do
    before(:each) do
      AppConf.roles = :app
      AppConf.apps = {'name' => AppBuilder.new({:name => 'name', :db_password => 'PASSWORD'})}
    end

    context 'development, test' do
      it 'sets permissions for each app to access database' do
        [:development, :test].each do |env|
          AppConf.commands = []
          AppConf.environment = env
          eval_package
          AppConf.commands.map(&:info).should == [
            "TASK   dbperms - Set app permissions to database",
            %{RUN    echo "GRANT ALL ON *.* TO 'name'@'%' IDENTIFIED BY 'PASSWORD';" | mysql -u root -pDBPASS -h DBIP}
          ]
        end
      end
    end

    context 'staging, production' do
      it 'sets permissions for each app to access database' do
        [:staging, :production].each do |env|
          AppConf.commands = []
          AppConf.environment = env
          eval_package
          AppConf.commands.map(&:info).should == [
            "TASK   dbperms - Set app permissions to database",
            %{RUN    echo "GRANT ALL ON *.* TO 'name'@'%' IDENTIFIED BY 'PASSWORD';" | mysql -u root -pDBPASS -h DBIP},
          ]
        end
      end
    end
  end

  context 'dbmaster role' do
    it 'sets up replication master' do
      AppConf.roles = :dbmaster
      eval_package
      AppConf.commands.map(&:info).should == [
        "TASK   replication - Setup database replication",
        "UPLOAD mysql/dbmaster.cnf to upload#{@time.to_i}",
        "SUDO   cp upload#{@time.to_i} /etc/mysql/conf.d/dbmaster.cnf",
        "RUN    rm -f upload#{@time.to_i}",
        "RUN    echo \"GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY 'REPL_PASS';\" | mysql -u root -pDBPASS -h TARGET"
      ]
    end
  end

  context 'dbslave role' do
    it 'sets up replication slave' do
      AppConf.roles = :dbslave
      eval_package
      AppConf.commands.map(&:info).should == [
        "TASK   replication - Setup database replication",
        "UPLOAD mysql/dbslave.cnf to upload#{@time.to_i}",
        "SUDO   cp upload#{@time.to_i} /etc/mysql/conf.d/dbslave.cnf",
        "RUN    rm -f upload#{@time.to_i}",
        "RUN    echo \"CHANGE MASTER TO MASTER_HOST='DBMASTER', MASTER_USER='repl' MASTER_PASSWORD='REPL_PASS';\" | mysql -u root -pDBPASS -h TARGET"
      ]
    end
  end
end

