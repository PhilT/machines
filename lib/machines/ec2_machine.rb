module Machines
  module Ec2Machine
    def connect_to_ec2
      begin
        require 'aws-sdk'
      rescue LoadError
        say 'aws_sdk gem required to use ec2/s3 features', :red
        say 'please gem install aws-sdk', :red
        raise
      end

      AppConf.ec2.connection = AWS::EC2.new(
        :access_key_id => AppConf.ec2.access_key_id,
        :secret_access_key => AppConf.ec2.secret_access_key,
        :ec2_endpoint => AppConf.ec2.endpoint
      )
    end

    def run_instance
      instance_options = {
        :key_name => File.basename(AppConf.ec2.private_key_file, '.key'),
        :security_group => AppConf.ec2.security_group,
        :instance_type => AppConf.ec2.type,
        :image_id => AppConf.ec2.ami,
        :monitoring_enabled => false # Is this enabled later or do I need to allow it to be configured?
      }

      AppConf.ec2.instance_id = AppConf.ec2.connection.run_instances(instance_options)['instancesSet']['item'][0]['instanceId']
      wait_for_running_state(300)
    end

    def wait_for_running_state(timeout)
      later = Time.now + timeout
      while 'running' != AppConf.ec2.connection.describe_instances(:instance_id => AppConf.ec2.instance_id)['reservationSet']['item'][0]['instancesSet']['item'][0]['instanceState']['name']
        sleep 5
        raise TimeoutError, "Timed out waiting for instance to start. Instance ID: #{AppConf.ec2.instance_id}" if Time.now > later
      end
    end
  end
end

