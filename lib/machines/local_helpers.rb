module Machines
  module LocalHelpers
    # Loads a YAML file from the project directory
    def from_yaml(path)
      path = File.join(AppConf.project_dir, path)
      YAML.load(File.open(path))
    end
  end
end

