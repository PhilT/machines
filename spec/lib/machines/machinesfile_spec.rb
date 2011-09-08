require 'spec_helper'

describe 'Machinesfile' do
  include Machines::Machinesfile
  include Machines::AppSettings

  describe 'machine' do
    it 'adds the machine configuration to the machines hash' do
      AppConf.machines = {}
      machine 'machine', :test, :apps => ['app', 'another'], :roles => [:role]
      AppConf.machines['machine'].should == {:environment => :test, :apps => ['app', 'another'], :roles => [:role]}
    end
  end

  describe 'package' do
    it 'raises specific error when failing to load Machinesfile' do
      File.should_not_receive(:read)
      lambda{ package 'Machinesfile' }.should raise_error LoadError, /Cannot find Machinesfile/
    end

    it 'loads custom package when it exists' do
      custom_package = "packages/custom_package.rb"
      FileUtils.mkdir_p File.dirname(custom_package)
      FileUtils.touch custom_package
      File.should_receive(:read).with(custom_package).and_return ''
      package :custom_package
    end

    it 'loads built-in package when no custom package' do
      builtin_package = "#{AppConf.application_dir}/packages/builtin_package.rb"
      FileUtils.mkdir_p File.dirname(builtin_package)
      FileUtils.touch builtin_package
      File.should_receive(:read).with(builtin_package).and_return ''
      package :builtin_package
    end

    it 'raises when no custom and no built-in package' do
      File.should_not_receive(:read)
      lambda { package :builtin_package}.should raise_error LoadError, /Cannot find .* package builtin_package/
    end
  end
end

