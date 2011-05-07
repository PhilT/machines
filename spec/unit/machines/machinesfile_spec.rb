require 'spec_helper'

describe 'Machinesfile' do
  include Machines::Machinesfile
  include Machines::AppSettings

  describe 'machine' do
    before(:each) do
      AppConf.environment = nil
      AppConf.environments = nil
      AppConf.roles = nil
    end

    it 'sets environment, apps and role when it matches the configuration specified' do
      should_receive(:load_app_settings).with(['app', 'another'])
      AppConf.machine = 'machine'
      AppConf.from_hash(:user => {:name => 'user'})

      machine 'machine', :test, :apps => ['app', 'another'], :roles => [:role]

      AppConf.environment.should == :test
      AppConf.environments.should == :test
      AppConf.roles.should == [:role]
    end

    it 'nothing set when it does not match specified configuration' do
      AppConf.machine = 'something else'
      machine 'config', :test, :apps => ['app', 'another'], :roles => [:role]
      AppConf.environment.should be_nil
      AppConf.environments.should be_nil
      AppConf.roles.should be_nil
    end
  end

  describe 'package' do
    it 'raises specific error when failing to load Machinesfile' do
      File.should_not_receive(:read)
      lambda{ package 'Machinesfile' }.should raise_error LoadError, /Cannot find Machinesfile/
    end

    it 'loads custom package when it exists' do
      custom_package = "#{AppConf.project_dir}/packages/custom_package.rb"
      File.new custom_package, 'w'
      File.should_receive(:read).with(custom_package).and_return ''
      package :custom_package
    end

    it 'loads built-in package when no custom package' do
      @builtin_package = "#{AppConf.application_dir}/packages/builtin_package.rb"
      File.new @builtin_package, 'w'
      File.should_receive(:read).with(@builtin_package).and_return ''
      package :builtin_package
    end

    it 'raises when no custom and no built-in package' do
      File.should_not_receive(:read)
      lambda { package :builtin_package}.should raise_error LoadError, /Cannot find .* package builtin_package/
    end
  end
end

