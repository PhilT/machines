require 'spec_helper'

describe 'Machinesfile' do
  include Machines::Machinesfile
  include Machines::AppSettings

  describe 'machine' do
    before(:each) do
      AppConf.environment = nil
      AppConf.roles = nil
    end

    it 'sets environment, apps and role when it matches the configuration specified' do
      should_receive(:load_app_settings).with(['app', 'another'])
      AppConf.machine = 'machine'
      AppConf.from_hash(:user => {:name => 'user'})

      machine 'machine', :test, :apps => ['app', 'another'], :roles => [:role]

      AppConf.environment.should == :test
      AppConf.roles.should == [:role]
    end

    it 'nothing set when it does not match specified configuration' do
      AppConf.machine = 'something else'
      machine 'config', :test, :apps => ['app', 'another'], :roles => [:role]
      AppConf.environment.should be_nil
      AppConf.roles.should be_nil
    end
  end

  describe 'package' do
    it 'loads custom package when it exists' do
      custom_package = "#{AppConf.project_dir}/packages/custom_package.rb"
      File.stub(:exists?).with(custom_package).and_return true
      should_receive(:load).with(custom_package).and_return true
      package :custom_package
    end

    it 'loads built-in package when no custom package' do
      @builtin_package = "#{AppConf.application_dir}/packages/builtin_package.rb"
      File.stub(:exists?).with("#{AppConf.project_dir}/packages/builtin_package.rb").and_return false
      File.stub(:exists?).with(@builtin_package).and_return true
      should_receive(:load).with(@builtin_package).and_return true
      package :builtin_package
    end

    it 'raises when no custom and no built-in package' do
      should_not_receive(:load)
      File.stub(:exists?).with("#{AppConf.project_dir}/packages/builtin_package.rb").and_return false
      File.stub(:exists?).with("#{AppConf.application_dir}/packages/builtin_package.rb").and_return false
      lambda {package :builtin_package}.should raise_error LoadError
    end
  end
end

