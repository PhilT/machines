require 'spec_helper'

describe 'packages/mysql' do
  before(:each) do
    load_package('mysql')

    $conf.from_hash(:machine => {
      :address => 'DB_IP',
      :root_pass => 'DB_PASS',
      :replication_user => 'REPL_USER',
      :replication_pass => 'REPL_PASS'
    })
    $conf.from_hash(:db_server => {
      :address => 'SERVER_IP',
      :root_pass => 'SERVER_PASS',
      :replication_user => 'REPL_USER',
      :replication_pass => 'REPL_PASS'
    })
  end

  describe 'db role' do
    it 'installs MySQL' do
      $conf.roles = :db

      eval_package
      $conf.commands.map(&:info).must_equal [
        "TASK   mysql - Install MySQL",
        "SUDO   echo mysql-server-5.1 mysql-server/root_password password DB_PASS | debconf-set-selections",
        "SUDO   echo mysql-server-5.1 mysql-server/root_password_again password DB_PASS | debconf-set-selections",
        "SUDO   apt-get -q -y install mysql-server",
        "SUDO   apt-get -q -y install libmysqlclient-dev",
        "RUN    service mysqld restart"
      ]
    end
  end

  describe 'dbmaster role' do
    it 'sets permissions for each app to access database and grants replication rights for slave' do
      $conf.roles = :dbmaster
      $conf.webapps = {'name' => AppBuilder.new({:name => 'name', :password => 'PASSWORD'})}
      eval_package
      $conf.commands.map(&:info).must_equal [
        "TASK   dbperms - Grant applications access to the database",
        %{RUN    echo "GRANT ALL ON *.* TO 'name'@'%' IDENTIFIED BY 'PASSWORD';" | mysql -u root -pDB_PASS},
        "TASK   replication - Grant replication access to this machine",
        "UPLOAD mysql/dbmaster.cnf to /tmp/dbmaster.cnf",
        "SUDO   cp -rf /tmp/dbmaster.cnf /etc/mysql/conf.d/dbmaster.cnf",
        "RUN    rm -rf /tmp/dbmaster.cnf",
        "RUN    echo \"GRANT REPLICATION SLAVE ON *.* TO 'REPL_USER'@'%' IDENTIFIED BY 'REPL_PASS';\" | mysql -u root -pDB_PASS"
      ]
    end
  end

  describe 'dbslave role' do
    it 'sets up slave to replicate from master' do
      $conf.roles = :dbslave
      eval_package
      $conf.commands.map(&:info).must_equal [
        "TASK   replication - Setup database replication from master",
        "UPLOAD mysql/dbslave.cnf to /tmp/dbslave.cnf",
        "SUDO   cp -rf /tmp/dbslave.cnf /etc/mysql/conf.d/dbslave.cnf",
        "RUN    rm -rf /tmp/dbslave.cnf",
        "RUN    echo \"CHANGE MASTER TO MASTER_HOST='SERVER_IP', MASTER_USER='REPL_USER' MASTER_PASSWORD='REPL_PASS';\" | mysql -u root -pDB_PASS"
      ]
    end
  end
end

