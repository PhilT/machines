module Machines
  module LocalHelpers
    # Appends a string to a file locally
    # @param [String] string String to append
    # @param [String] path Path to append string to
    def append string, path
      File.open(path, 'a') {|file| file.puts string }
    end

    # Loads a YAML file from the project directory
    def from_yaml(path)
      path = File.join(AppConf.project_dir, path)
      YAML.load(File.open(path))
    end
  end
end

