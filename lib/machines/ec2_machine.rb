module Machines
  module Ec2Machine
    def connect
      say 'Connecting to EC2...'
      @ec2 = AWS::EC2::Base.new(
        :access_key_id => AppConf.ec2.access_key_id,
        :secret_access_key => AppConf.ec2.secret_access_key,
        :server => AppConf.ec2.url
      )
    end

    def run_instance
      say 'Starting new Ubuntu instance...'
      instance_options = {
        :key_name => File.basename(AppConf.ec2.private_key_file, '.key'),
        :security_group => AppConf.ec2.security_group,
        :instance_type => AppConf.ec2.type,
        :image_id => AppConf.ec2.ami,
        :monitoring_enabled => false # Is this enabled later or do I need to allow it to be configured?
      }

      @instance_id = @ec2.run_instances(instance_options)['instancesSet']['item'].first['instanceId']
      wait_for lambda{instance_state(@ec2, @instance_id) == 'running'}
    end
  end
end

