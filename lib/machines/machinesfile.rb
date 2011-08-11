module Machines
  module Machinesfile
    # Add a machine configuration
    def machine name, environment, options = {:apps => [], :roles => []}
      AppConf.machines[name] = {:environment => environment, :apps => options[:apps], :roles => options[:roles]}
    end

    def package name
      if name == 'Machinesfile'
        error = 'Cannot find Machinesfile. Use `machines generate` to create a template.'
      else
        error = "Cannot find custom or built-in package #{name}."
      end
      package = load_and_eval(AppConf.project_dir, name)
      package ||= load_and_eval(AppConf.application_dir, name)
      package || raise(LoadError, error, caller)
    end

  private
    def load_and_eval base_dir, name
      package_name = File.join(base_dir, 'packages', "#{name}.rb")
      if File.exists?(package_name)
        eval(File.read(package_name), nil, "eval: #{package_name}")
        true
      else
        false
      end
    end
  end
end

