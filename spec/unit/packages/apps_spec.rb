require 'spec_helper'

describe 'Package: apps' do
  include Core
  include FileOperations

  before(:each) do
    FakeFS.deactivate!
  end

  after(:each) do
    FakeFS.activate!
  end

  it '' do
    AppConf.apps = []
    AppConf.server = 'path'
    AppConf.webserver = 'server'
    AppConf.from_hash(:nginx => {:path => 'nginx_path', :app_servers => 'servers'})

    package = File.read(File.join(AppConf.application_dir, 'packages/apps.rb'))
    eval package
  end
end

