require 'date'

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

    def prepare_log_file
      log_to :file, "Starting Installation at #{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')}\n", 'w'
    end

    def log_to where, message, mode = 'a'
      f = where == :file ? File.open("output.log", mode) : $stdout
      f.puts message if message
      f.close if where == :file
    end

    def log_result_to_file check, message
      return unless message
      puts message
      File.open("output.log", 'a') do |f|
        passed = message.split("\n").last.scan(/CHECK PASSED/).any?
        if passed
          f.puts "CHECK PASSED".green
        else
          f.puts "CHECK '#{check}' failed...".red
          f.puts message.red
          f.puts ''
        end
      end
    end

    # Queues up a command on the command list. Includes the calling method name for logging
    def add command, check
      line = ''
      caller.each do |methods|
        line = methods.scan(/Machinesfile:([0-9]+)/).join
        break if line.any?
      end
      @commands << [line, command, check]
    end

  end
end

