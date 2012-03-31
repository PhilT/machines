module Machines
  module CloudMachine
    def connect_to_cloud
      begin
        require 'fog'
      rescue LoadError
        say 'fog gem required to use cloud features.'
        say 'Please "gem install fog".'
        raise
      end

      Fog.credential = 'machines_key'
      options = symbolize_keys($conf.cloud.to_hash)
      options.merge!(:region => $conf.machine.cloud.region)
      $conf.cloud.connection = Fog::Compute.new(options)
    end

    def create_server
      server = $conf.cloud.connection.servers.create(
        :private_key_path => $conf.machine.cloud.private_key_path,
        :public_key_path => $conf.machine.cloud.public_key_path,
        :username => $conf.machine.cloud.username,
        :flavor_id => $conf.machine.cloud.flavor_id,
        :image_id => $conf.machine.cloud.image_id)
      server.wait_for { ready? }
    end

    def symbolize_keys hash
      hash.inject({}){|new_hash, (k, v)| new_hash[k.to_sym] = v; new_hash }
    end
  end
end

