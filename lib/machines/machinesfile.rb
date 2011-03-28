module Machines
  module Machinesfile

    def package name
      load_package(AppConf.project_dir, name) || load_package(AppConf.application_dir, name) ||
        raise(LoadError, "Cannot find custom or built-in package #{name}", caller)
    end

    def roles *args, &block

    end

    def users *args, &block
    end

    def environments *args, &block

    end

  private
    def load_package base_dir, name
      package_name = File.join(base_dir, 'packages', "#{name}.rb")
      load package_name if File.exists?(package_name)
    end

  end
end

