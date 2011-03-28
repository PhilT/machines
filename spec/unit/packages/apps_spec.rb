require 'spec_helper'


describe 'Apps' do
  describe 'make_app_structure' do
    it 'should add commands to create the app folder structure' do
      pending
      AppConf.from_hash({'user' => {'name' => 'user'}})

      # Need to setup mocks before running apps.rb
      # require 'packages/apps'
      @added.should == [
        'mkdir -p path/releases', 'chown user:user path/releases',
        'mkdir -p path/shared/config', 'chown user:user path/shared/config',
        'mkdir -p path/shared/system', 'chown user:user path/shared/system'
      ]
    end
  end
end

