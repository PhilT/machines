require 'spec_helper'

describe 'packages/webapps' do
  before(:each) do
    load_package('webapps')

    $conf.from_hash(:user => {:name => 'username', :home => 'home_dir'}, :ruby => {:version => 'ruby_version'})
    $conf.webapps = {'application' => AppBuilder.new('scm' => 'github.com/project', 'name' => 'application',
      'url' => 'github url', 'path' => '/home/users/app_path', 'enable_ssl' => nil, 'db_password' => 'pa55', 'server_name' => 'app.dev')}
    $conf.from_hash(:awstats => {:path => 'stats_path'})
    $conf.from_hash(:webserver => {:name => 'nginx', :path => 'nginx_path', :servers_dir => 'servers'})
    $conf.from_hash(:db_server => {:address => 'db_master'})
    FileUtils.mkdir_p 'nginx'
    File.open('nginx/app_server.conf.erb', 'w') {|f| f.puts 'the template' }
  end

  it 'adds the following commands' do
    $conf.environment = 'production'
    eval_package
    $conf.commands.map(&:info).map{|info| info.gsub(" \n", "\n")}.must_equal [
      "TASK   webapps - Sets up Web apps in config/webapps.yml using app_server.conf.erb",
      "SUDO   mkdir -p nginx_path/servers",
      "RUN    mkdir -p /home/users/app_path/releases",
      "RUN    mkdir -p /home/users/app_path/shared/config",
      "RUN    mkdir -p /home/users/app_path/shared/system",
      "RUN    mkdir -p /home/users/app_path/shared/log",
      "UPLOAD buffer from nginx/app_server.conf.erb to /tmp/application.conf",
      "SUDO   cp -rf /tmp/application.conf nginx_path/servers/application.conf",
      "RUN    rm -rf /tmp/application.conf",
      "SUDO   mkdir -p /var/log/nginx",
      'UPLOAD buffer from database.yml to /home/users/app_path/shared/config/database.yml',
      'SUDO   echo "127.0.0.1 app.dev" >> /etc/hosts'
    ]
  end

  it "doesn't make app structure when target is a development machine" do
    $conf.from_hash(:ruby => {:gems_path => '.rbenv'})
    $conf.environment = 'development'
    eval_package
    $conf.commands.map(&:info).map{|info| info.gsub(" \n", "\n")}.must_equal [
      "TASK   webapps - Sets up Web apps in config/webapps.yml using app_server.conf.erb",
      "SUDO   mkdir -p nginx_path/servers",
      "RUN    git clone -q github.com/project /home/users/app_path",
      "RUN    cd /home/users/app_path && $HOME/.rbenv/bin/rbenv exec bundle",
      "UPLOAD buffer from nginx/app_server.conf.erb to /tmp/application.conf",
      "SUDO   cp -rf /tmp/application.conf nginx_path/servers/application.conf",
      "RUN    rm -rf /tmp/application.conf",
      "SUDO   mkdir -p /var/log/nginx",
      'SUDO   echo "127.0.0.1 app.dev" >> /etc/hosts'
    ]
  end
end

