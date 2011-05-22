require 'spec_helper'

describe 'Package: apps' do
  include Core
  include FileOperations
  include AppSettings
  include Configuration
  include Database

  before(:each) do
    FakeFS.deactivate!

    AppConf.project_dir = 'tmp/project'
    AppConf.from_hash(:user => {:name => 'username', :home => 'home_dir'}, :ruby => {:version => 'ruby_version'})
    AppConf.apps = {'application' => AppBuilder.new('name' => 'application', 'path' => 'app_path', 'enable_ssl' => nil)}
    AppConf.webserver = 'nginx'
    AppConf.from_hash(:nginx => {:path => 'nginx_path', :servers_dir => 'servers'})
    @package = File.read(File.join(AppConf.application_dir, 'packages/apps.rb'))

    AppConf.from_hash(:db => {:address => 'db master'})
  end

  after(:each) do
    FakeFS.activate!
  end

  it 'adds apps to commands to be run' do

    eval @package
    AppConf.commands.should == []
  end

  it "doesn't make app structure when target is a development machine" do
    AppConf.environment = :development
    eval @package
    AppConf.commands.should == []
  end
end

