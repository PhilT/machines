require 'date'

module Machines
  module Helpers
    # Utility method to tidy up commands before being logged
    def display command
      command = command.join(' to ') if command.is_a?(Array)
      command = command.gsub(/(#{(AppConf.passwords).join('|')})/, "*****") if AppConf.passwords && AppConf.passwords.any?
      command
    end

    # Validate some methods that require certain options
    def required_options options, required
      required.each do |option|
        raise ArgumentError, "Missing option '#{option}'. Check trace for location of the problem." unless options[option]
      end
    end

    def log_progress progress, message, success
      message = $terminal.color("[#{"%03d" % progress} / #{"%03d" % AppConf.commands.size}] #{message}", success ? :green : :red)
      if success
        AppConf.log.progress.info message
      else
        AppConf.log.progress.error message
      end
    end

    def log_output message, color = :white
      AppConf.log.output.info $terminal.color(message, color)
    end

    def check_result result
      result.scan(/CHECK PASSED|CHECK FAILED/).first || 'NOT CHECKED'
    end

    def log_result result
      color = {'NOT CHECKED' => :yellow, 'CHECK FAILED' => :red, 'CHECK PASSED' => :green}[result]
      AppConf.log.output.info $terminal.color(result, color)
    end

  end
end

