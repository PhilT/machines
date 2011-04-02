module Machines
  module Machinesfile
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
      load package_name if File.exists?(package_name)
    end

  end
end

