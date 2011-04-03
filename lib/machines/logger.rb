require 'date'

module Machines
  module Logger

    HighLine.color_scheme = HighLine::ColorScheme.new do |cs|
      cs[:highlight]  = [:bold]
      cs[:warning]    = [:yellow]
      cs[:failure]    = [:red]
      cs[:success]    = [:green]
    end

    # Displays message on screen
    # @param [String] message Message to display
    # @param [Hash] options
    # @option options [String] :line Prepends progress like [001/010]
    # @option options [String] :success True displays text in green, false in red
    # @option options [String] :color Color the text (overrides :success)
    def put message, options = {}
      say format_message(message, options)
    end

    # Logs a message to log/output.log
    # @param [String] message Message to log
    # @param [Hash] options
    # @option options [String] :line Prepends progress like [001/010]
    # @option options [String] :success True logs text in green, false in red
    # @option options [String] :color Color the text (overrides :success)
    def log message, options = {}
      AppConf.log.puts format_message(message, options)
    end

    def format_message message, options
      message = hide_passwords message
      message = "(#{"%03d" % (options[:progress] + 1)}/#{"%03d" % AppConf.commands.count}) #{message}" if options[:progress]
      color = options[:color] || {nil => nil, true => :success, false => :failure}[options[:success]]
      message = $terminal.color(message, color) if color
      message
    end

    # Stars out passwords in logs and screen
    def hide_passwords message
      AppConf.passwords.any? ? message.gsub(/(#{(AppConf.passwords).join('|')})/, "*****") : message
    end

    def check_result result
      result.scan(/CHECK PASSED|CHECK FAILED/).first || 'NOT CHECKED'
    end

    def color_for result
      {'NOT CHECKED' => :warning, 'CHECK FAILED' => :failure, 'CHECK PASSED' => :success}[result]
    end
  end
end

