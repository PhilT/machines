module Machines
  module Setttings
    class AppBuilder < OpenStruct
      def get_binding
        binding
      end
    end

    class AppSettings
      # Loads application settings from config/apps.yml and makes them available in AppConf.apps
      def self.load
        yaml = from_yaml('config/apps.yml')
        AppConf.apps = []
        yaml.each do |app_name, app_hash|
          app = AppBuilder.new
          app.name = app_name
          app.path = File.join(AppConf.appsroot, app.path)
          app.ssl_key = app_hash[AppConf.environment].ssl + '.key'
          app.ssl_crt = app_hash[AppConf.environment].ssl + '.crt'
          app_hash.each do |k, v|
            app[k] = v unless v.is_a?(Hash)
          end

          app_hash[AppConf.environment].each do |k, v|
            app[k] = v
          end
          AppConf.apps << app
        end
      end
    end
  end
end

