require 'spec_helper'

describe 'packages/webapps' do
  include Core
  include FileOperations
  include AppSettings
  include Configuration
  include Database

  before(:each) do
    FakeFS.deactivate!
    @package = File.read(File.join(AppConf.application_dir, 'packages/webapps.rb'))
    FakeFS.activate!

    AppConf.from_hash(:user => {:name => 'username', :home => 'home_dir'}, :ruby => {:version => 'ruby_version'})
    AppConf.apps = {'application' => AppBuilder.new('name' => 'application', 'path' => 'app_path', 'enable_ssl' => nil)}
    AppConf.webserver = 'nginx'
    AppConf.from_hash(:nginx => {:path => 'nginx_path', :servers_dir => 'servers'})
    AppConf.from_hash(:db => {:address => 'db_master'})
    FileUtils.mkdir_p '/tmp/nginx'
    File.open('/tmp/nginx/app_server.conf.erb', 'w') {|f| f.puts 'the template' }
  end

  it 'adds the following commands' do
    AppConf.environment = :production
    eval @package
    AppConf.commands.map(&:info).should == [
      "RUN    mkdir -p nginx_path/servers",
      "RUN    mkdir -p app_path/releases",
      "RUN    mkdir -p app_path/shared/config",
      "RUN    mkdir -p app_path/shared/system",
      "RUN    echo \"the template\n\" > nginx_path/servers/application.conf",
      "RUN    echo \"--- \nproduction: \n  adapter: mysql\n  database: application\n  username: application\n  password: \n  host: db_master\n  encoding: utf8\n\" > app_path/shared/config/database.yml"
    ]
  end

  it "doesn't make app structure when target is a development machine" do
    AppConf.environment = :development
    eval @package
    AppConf.commands.map(&:info).should == [
      "RUN    mkdir -p nginx_path/servers",
      "RUN    echo \"the template\n\" > nginx_path/servers/application.conf",
      "RUN    echo \"--- \ndevelopment: \n  adapter: mysql\n  database: application\n  username: application\n  password: \n  host: db_master\n  encoding: utf8\n\" > app_path/shared/config/database.yml"
    ]
  end
end

