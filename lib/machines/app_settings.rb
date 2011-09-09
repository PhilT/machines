module Machines
  module AppSettings
    class AppBuilder < OpenStruct
      def get_binding
        binding
      end
    end

    # Loads application settings from config/webapps.yml and makes them available in AppConf.webapps
    def load_app_settings(apps)
      yaml = YAML.load(File.open('config/webapps.yml'))
      yaml.select{|name| apps.include?(name) }.each do |app_name, settings|
        environment = settings[AppConf.environment.to_s] || raise(ArgumentError, 'No setttings for specified environment')
        environment['db_password'] ||= app_name
        settings['name'] = app_name
        settings['path'] = File.join(AppConf.appsroot, settings['path'])
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

