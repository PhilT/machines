module Machines
  module Helpers
    # Utility method to tidy up commands before being logged
    def display command
      command = command.to_a.join(' ').gsub("\n ", "\\")
      command.gsub!(/(#{(@passwords.values).join('|')})/, "***") if @passwords.values.any?
      command
    end

    # Validate some methods that require certain options
    def required_options options, required
      required.each do |option|
        raise ArgumentError, "Missing option '#{option}'. Check trace for location of the problem." unless options[option]
      end
    end

    # Log a message to the screen
    def log message
      puts message
    end

    # Queues up a command on the command list. Includes the calling method name for logging
    def add command, check
      @commands << ["#{caller[0][/`([^']*)'/, 1]}", command, check] # interpolated to stop hilight bug in gedit
    end
  end
end

