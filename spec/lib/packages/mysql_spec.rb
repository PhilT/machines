require 'spec_helper'

describe 'packages/mysql' do
  before(:each) do
    $conf.from_hash(:machine => {
      :address => 'db_ip',
      :root_pass => 'db_pass',
      :replication_user => 'repl_user',
      :replication_pass => 'repl_pass'
    })
    $conf.from_hash(:db_server => {
      :address => 'server_ip',
      :root_pass => 'server_pass',
      :replication_user => 'repl_user',
      :replication_pass => 'repl_pass'
    })
  end

  describe 'db role' do
    it 'installs MySQL' do
      $conf.roles = :db

      eval_package
      $conf.commands.map(&:info).must_equal [
        "TASK   mysql - Install MySQL",
        "SUDO   echo mysql-server-5.5 mysql-server/root_password password db_pass | debconf-set-selections",
        "SUDO   echo mysql-server-5.5 mysql-server/root_password_again password db_pass | debconf-set-selections",
        "SUDO   apt-get -q -y install mysql-server",
        "SUDO   apt-get -q -y install mysql-client",
        "SUDO   apt-get -q -y install libmysqlclient-dev",
        "RUN    service mysql restart"
      ]
    end
  end

  describe 'dbmaster role' do
    it 'sets permissions for each app to access database and grants replication rights for slave' do
      $conf.roles = :dbmaster
      $conf.webapps = {'name' => AppSettings::AppBuilder.new({database: 'database', username: 'username', password: 'password'})}
      eval_package
      $conf.commands.map(&:info).join("\n").must_equal [
        "TASK   dbperms - Grant applications access to the database",
        %{RUN    echo "GRANT ALL ON database.* TO 'username'@'%' IDENTIFIED BY 'password';" | mysql -u root -pdb_pass},
        "TASK   replication - Grant replication access to this machine",
        "UPLOAD mysql/dbmaster.cnf to /tmp/dbmaster.cnf",
        "SUDO   cp -rf /tmp/dbmaster.cnf /etc/mysql/conf.d/dbmaster.cnf",
        "RUN    rm -rf /tmp/dbmaster.cnf",
        "RUN    echo \"GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%' IDENTIFIED BY 'repl_pass';\" | mysql -u root -pdb_pass"
      ].join("\n")
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
        "RUN    echo \"CHANGE MASTER TO MASTER_HOST='server_ip', MASTER_USER='repl_user' MASTER_PASSWORD='repl_pass';\" | mysql -u root -pdb_pass"
      ]
    end
  end
end

