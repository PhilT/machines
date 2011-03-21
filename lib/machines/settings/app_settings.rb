module Machines
  module AppSettings
    class AppBuilder < OpenStruct
      def get_binding
        binding
      end
    end

    # Loads application settings from config/apps.yml and makes them available in AppConf.apps
    def load_app_settings
      yaml = from_yaml('config/apps.yml')
      AppConf.apps = []
      environment = AppConf.environment.to_s
      yaml.each do |app_name, app_hash|
        app = AppBuilder.new
        app.name = app_name
        app.path = File.join(AppConf.appsroot, app.name)
        if app_hash[environment].ssl
          app.ssl_key = app_hash[environment].ssl + '.key'
          app.ssl_crt = app_hash[environment].ssl + '.crt'
        end
        app_hash.each do |k, v|
          app.send("#{k}=", v) unless v.is_a?(Hash)
        end

        app_hash[environment].each do |k, v|
          app.send("#{k}=", v)
        end
        AppConf.apps << app
      end
    end
  end
end

