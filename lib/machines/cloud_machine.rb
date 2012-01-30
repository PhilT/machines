module Machines
  module CloudMachine
    def connect_to_cloud
      begin
        require 'fog'
      rescue LoadError
        say 'fog gem required to use cloud features.', :red
        say 'Please "gem install fog".', :red
        raise
      end

      Fog.credential = 'machines_key'
      options = symbolize_keys(AppConf.cloud.to_hash)
      options.merge!(:region => AppConf.machine.cloud.region)
      AppConf.cloud.connection = Fog::Compute.new(options)
    end

    def create_server
      server = AppConf.cloud.connection.servers.create(
        :private_key_path => AppConf.machine.cloud.private_key_path,
        :public_key_path => AppConf.machine.cloud.public_key_path,
        :username => AppConf.machine.cloud.username,
        :flavor_id => AppConf.machine.cloud.flavor_id,
        :image_id => AppConf.machine.cloud.image_id)
      server.wait_for { ready? }
    end

    def symbolize_keys hash
      hash.inject({}){|new_hash, (k, v)| new_hash[k.to_sym] = v; new_hash }
    end
  end
end

