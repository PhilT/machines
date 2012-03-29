require 'spec_helper'

describe 'Machinesfile' do
  describe 'package' do
    it 'raises specific error when failing to load Machinesfile' do
      File.should_not_receive(:read)
      lambda{ package 'Machinesfile' }.must_raise LoadError, /Cannot find Machinesfile/
    end

    it 'loads custom package when it exists' do
      custom_package = "packages/custom_package.rb"
      FileUtils.mkdir_p File.dirname(custom_package)
      FileUtils.touch custom_package
      File.expects(:read).with(custom_package).returns ''
      package :custom_package
    end

    it 'loads built-in package when no custom package' do
      builtin_package = "#{AppConf.application_dir}/packages/builtin_package.rb"
      FileUtils.mkdir_p File.dirname(builtin_package)
      FileUtils.touch builtin_package
      File.expects(:read).with(builtin_package).returns ''
      package :builtin_package
    end

    it 'raises when no custom and no built-in package' do
      File.should_not_receive(:read)
      lambda { package :builtin_package}.must_raise LoadError, /Cannot find .* package builtin_package/
    end
  end
end

