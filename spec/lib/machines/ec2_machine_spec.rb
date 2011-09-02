require 'spec_helper'
require 'aws-sdk'

describe 'Ec2Machine' do
  include Ec2Machine

  before(:each) do
    AppConf.from_hash(:ec2 => {
      :connection => nil,
      :access_key_id => 'access_key_id',
      :secret_access_key => 'secret_access_key',
      :endpoint => 'url',
      :private_key_file => 'certs/private_key_file.key',
      :security_group => 'security_group',
      :type => 'type',
      :ami => 'ami'
    })
  end

  describe 'connect' do
    it 'ensure settings are correctly passed to API' do
      AWS::EC2.should_receive(:new).with(
        :access_key_id => 'access_key_id',
        :secret_access_key => 'secret_access_key',
        :ec2_endpoint => 'url'
      ).and_return 'ec2_connection'
      connect_to_ec2
      AppConf.ec2.connection.should == 'ec2_connection'
    end

  end

  describe 'run_instance' do
    it 'ensure settings are correctly passed to API' do
      should_receive(:wait_for_running_state)
      options = {
        :key_name => 'private_key_file',
        :security_group => 'security_group',
        :instance_type => 'type',
        :image_id => 'ami',
        :monitoring_enabled => false
      }
      AppConf.ec2.connection = mock AWS::EC2::Base
      AppConf.ec2.connection.should_receive(:run_instances).with(options).and_return({
        'instancesSet' => {
          'item' => [
            {'instanceId' => 'id'}
          ]
        }
      })
      run_instance
      AppConf.ec2.instance_id.should == 'id'
    end
  end

  describe 'wait_for_running_state' do
    def options state
      {
        'reservationSet' => {
          'item' => [
            'instancesSet' => {
              'item' => [{
                'instanceState' => {
                  'name' => state
                }
              }]
            }
          ]
        }
      }
    end

    it 'running' do
      AppConf.ec2.instance_id = 'instance_id'
      AppConf.ec2.connection = mock AWS::EC2::Base
      AppConf.ec2.connection.should_receive(:describe_instances).with({:instance_id => 'instance_id'}).and_return(options('running'))
      should_not_receive(:sleep)
      wait_for_running_state(1)
    end

    it 'times out' do
      AppConf.ec2.instance_id = 'instance_id'
      AppConf.ec2.connection = mock AWS::EC2::Base
      AppConf.ec2.connection.should_receive(:describe_instances).with({:instance_id => 'instance_id'}).and_return(options('starting'))
      Time.stub(:+).and_return Time.now
      should_receive(:sleep)
      lambda{ wait_for_running_state(0) }.should raise_error TimeoutError
    end
  end
end

