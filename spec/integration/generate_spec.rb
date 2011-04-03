require 'spec_helper'

describe 'Generate' do
  before(:each) do
    FakeFS.deactivate!
    FileUtils.rm_rf AppConf.project_dir
  end

  after(:each) do
    FakeFS.activate!
  end

  it 'creates an example project structure in the current directory' do
    Machines::Base.new.start('generate')
    files = %w(certificates) +
      %w(config/apps.yml config/config.yml) +
      %w(mysql nginx packages users Machinesfile)

    files.each do |name|
      File.should exist File.join(AppConf.project_dir, name)
    end
  end
end

