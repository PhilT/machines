require 'spec_helper'

describe 'Generate' do
  it 'creates an example project structure in the current directory' do
    FileUtils.rm_rf AppConf.project_dir
    Machines::Base.new.start('generate')
    files = %w(certificates) +
      %w(config/apps.yml config/config.yml) +
      %w(mysql nginx packages users Machinesfile)

    files.each do |name|
      File.should exist File.join(AppConf.project_dir, name)
    end
  end
end

