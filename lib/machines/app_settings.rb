module Machines
  module AppSettings
    class AppBuilder < OpenStruct
      def get_binding
        binding
      end
    end

    def generate_passwords
      $conf.webapps.keys.each do |webapp|
        $conf.webapps[webapp].keys.each do |environment|
          env_settings = $conf.webapps[webapp][environment]
          next unless env_settings.is_a?(AppConf)
          env_settings.password = generate_password unless env_settings.password
        end
      end
    end

    def load_and_generate_passwords_for_webapps
      $conf.load('webapps.yml')
      generate_passwords
      $conf.save('webapps', 'webapps.yml')
    end

    # Loads application settings from webapps.yml and makes them available in $conf.webapps as an
    # AppBuilder (bindable OpenStruct) so it can be used in ERB templates to generate config files
    # @param [Array] apps Names of the apps to configure
    def load_app_settings(apps)
      load_and_generate_passwords_for_webapps
      webapps = $conf.webapps.to_hash
      $conf.clear :webapps
      $conf.webapps = {}
      webapps.each do |app_name, settings|
        next unless apps.nil? || apps.include?(app_name)
        environment = settings[$conf.environment.to_s] || {}
        settings['name'] = app_name
        settings['path'] = File.join($conf.appsroot, app_name)
        public_path = "#{$conf.environment == 'development' ? '' : 'current/'}public"
        settings['root'] = File.join(settings['path'], public_path)

        environment.each { |k, v| settings[k] = v }
        if settings['cert']
          settings['ssl'] = true unless settings['ssl']
          settings['ssl_key'] = settings['cert'] + '.key'
          settings['ssl_crt'] = settings['cert'] + '.crt'
        end

        $conf.webapps[app_name] = AppBuilder.new(settings.reject{|k, v| v.is_a?(Hash) })
      end
    end

  end
end

