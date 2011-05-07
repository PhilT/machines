module Machines
  module Machinesfile
    # Add a machine configuration
    def machine name, environment, options = {:apps => [], :roles => []}
      if name == AppConf.machine
        AppConf.environment = AppConf.environments = environment
        AppConf.roles = options[:roles]
        load_app_settings(options[:apps])
      end
    end

    def package name
      if name == 'Machinesfile'
        error = 'Cannot find Machinesfile. Use `machines generate` to create a template.'
      else
        error = "Cannot find custom or built-in package #{name}."
      end
      load_package(AppConf.project_dir, name) ||
        load_package(AppConf.application_dir, name) ||
        raise(LoadError, error, caller)
    end

  private
    def load_package base_dir, name
      package_name = File.join(base_dir, 'packages', "#{name}.rb")
      if File.exists?(package_name)
        eval(File.read(package_name))
        true
      else
        false
      end
    end
  end
end

