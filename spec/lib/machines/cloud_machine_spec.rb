require 'spec_helper'
require 'fog'

describe 'CloudMachine' do
  include Machines::CloudMachine

  before do
    Fog.mock!
    $conf.from_hash(:cloud => {:provider => 'AWS', :aws_access_key_id => '123', :aws_secret_access_key => '456'})
    $conf.from_hash(:machine => {:cloud => {:flavor_id => 't1-micro', :image_id => 'ami-11f0cc65', :region => 'eu-west-1'}})
  end

  it 'displays an error message when fog gem is not available' do
    stubs(:require)
    expects(:require).with('fog').raises LoadError
    lambda do
      begin
        connect_to_cloud
      rescue LoadError
      end
    end.must_output "fog gem required to use cloud features.
Please \"gem install fog\".
"
  end

  it 'sets correct options and connects' do
    connect_to_cloud
    $conf.cloud.connection.must_be_kind_of Fog::Compute::AWS::Mock
  end

  it 'creates a server' do
    connect_to_cloud
    create_server
  end
end

