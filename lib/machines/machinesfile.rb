module Machines
  module Machinesfile
    def package name
      if name == 'Machinesfile'
        error = 'Cannot find Machinesfile. Use `machines generate` to create a template.'
      else
        error = "Cannot find custom or built-in package #{name}."
      end
      package = load_and_eval File.join('packages', "#{name}.rb")
      package ||= load_and_eval File.join($conf.application_dir, 'packages', "#{name}.rb")
      package || raise(LoadError, error, caller)
    end

  private
    def load_and_eval package_name
      if File.exists?(package_name)
        eval(File.read(package_name), nil, "eval: #{package_name}")
        true
      else
        false
      end
    end
  end
end

