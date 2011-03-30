require 'spec_helper'

describe 'Apps' do
  describe 'make_app_structure' do
    it 'should add commands to create the app folder structure' do
      pending
      AppConf.from_hash({'user' => {'name' => 'user'}})

      # Need to setup mocks before running apps.rb
      # require 'packages/apps'
      AppConf.commands.map(&:command).should == [
        'mkdir -p path/releases',
        'mkdir -p path/shared/config',
        'mkdir -p path/shared/system'
      ]
    end
  end
end

