require 'spec_helper'
require 'fog'

describe 'CloudMachine' do
  include CloudMachine

  before do
    Fog.mock!
    AppConf.from_hash(:cloud => {:provider => 'AWS', :aws_access_key_id => '123', :aws_secret_access_key => '456'})
    AppConf.from_hash(:machine => {:cloud => {:flavor_id => 't1-micro', :image_id => 'ami-11f0cc65', :region => 'eu-west-1'}})
  end

  it 'sets correct options and connects' do
    connect_to_cloud
    AppConf.cloud.connection.should be_a Fog::Compute::AWS::Mock
  end

  it 'creates a server' do
    connect_to_cloud
    create_server
  end
end

