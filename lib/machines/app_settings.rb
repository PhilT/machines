module Machines
  module AppSettings
    class AppBuilder < OpenStruct
      def get_binding
        binding
      end
    end

    def generate_passwords
      AppConf.webapps.keys.each do |webapp|
        AppConf.webapps[webapp].keys.each do |environment|
          env_settings = AppConf.webapps[webapp][environment]
          next unless env_settings.is_a?(AppConf)
          env_settings.password = generate_password unless env_settings.password
        end
      end
    end

    # Loads application settings from webapps.yml and makes them available in AppConf.webapps
    # as an AppBuilder (bindable OpenStruct) so it can be used in ERB templates to generate config files
    # @param [Array] apps Names of the apps to configure
    def load_app_settings(apps)
      load_and_generate_passwords_for_webapps
      webapps = AppConf.webapps.to_hash
      AppConf.clear :webapps
      AppConf.webapps = {}
      webapps.each do |app_name, settings|
        next unless apps.nil? || apps.include?(app_name)
        environment = settings[AppConf.environment.to_s] || raise(ArgumentError, "#{app_name} has no settings for #{AppConf.environment} environment")
        settings['name'] = app_name
        settings['path'] = File.join(AppConf.appsroot, File.basename(settings['scm'], '.git'))
        public_path = "#{AppConf.environment == :development ? '' : 'current/'}public"
        settings['root'] = File.join(settings['path'], public_path)
        if environment['ssl']
          settings['ssl_key'] = environment['ssl'] + '.key'
          settings['ssl_crt'] = environment['ssl'] + '.crt'
        end

        environment.each { |k, v| settings[k] = v }
        AppConf.webapps[app_name] = AppBuilder.new(settings.reject{|k, v| v.is_a?(Hash) })
      end
    end

    def load_and_generate_passwords_for_webapps
      AppConf.load('webapps.yml')
      generate_passwords
      AppConf.save('webapps', 'webapps.yml')
    end

  end
end

