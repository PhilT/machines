module Machines
  module AppSettings
    class AppBuilder < OpenStruct
      def get_binding
        binding
      end
    end

    # Loads application settings from config/webapps.yml and makes them available in AppConf.webapps
    # as an AppBuilder (bindable OpenStruct) so it can be used an ERB templates to generate config files
    # @param [Array] apps Names of the apps to configure
    def load_app_settings(apps)
      yaml = YAML.load_file('webapps.yml')
      yaml = yaml.select{|name| apps.include?(name) } if apps
      yaml.each do |app_name, settings|
        environment = settings[AppConf.environment.to_s] || raise(ArgumentError, "#{app_name} has no settings for #{AppConf.environment} environment")
        settings['name'] = app_name
        settings['full_path'] = File.join(AppConf.appsroot, settings['path'])
        public_path = "#{AppConf.environment == :development ? '' : 'current/'}public"
        settings['root'] = File.join(settings['full_path'], public_path)
        if environment['ssl']
          settings['ssl_key'] = environment['ssl'] + '.key'
          settings['ssl_crt'] = environment['ssl'] + '.crt'
        end

        environment.each { |k, v| settings[k] = v }
        AppConf.webapps[app_name] = AppBuilder.new(settings.reject{|k, v| v.is_a?(Hash) })
      end
    end
  end
end

