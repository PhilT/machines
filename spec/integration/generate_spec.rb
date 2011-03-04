require 'spec_helper'
require 'fileutils'

describe 'Generate' do
  before(:each) do
    FileUtils.rm_rf 'tmp/project'
    FileUtils.mkdir_p 'tmp/project'
    FileUtils.chdir 'tmp/project'
  end

  it 'creates an example project structure in the current directory' do
    Machines::Base.new.start('generate')
    files = %w(certificates) +
      %w(config/apps.yml config/config.yml config/packages.yml) +
      %w(mysql nginx packages users Machinesfile)

    files.each { |name| File.should exist(name) }
  end
end

