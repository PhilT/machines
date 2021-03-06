module Machines
  class Logger
    HighLine.color_scheme = HighLine::ColorScheme.new do |cs|
      cs[:highlight]  = [:bold, :blue]
      cs[:warning]    = [:yellow]
      cs[:failure]    = [:red]
      cs[:success]    = [:green]
      cs[:info]       = [:blue]
    end

    def initialize to, options = {}
      @to = to
      @truncate = options[:truncate]
    end

    # Logs a message
    # @param [String] message Message to display
    # @param [Hash] options
    # @option options [String] :progress Prepends number of commands completed
    # @option options [String] :color Color the text (overrides :success)
    # @option options [Bool] :newline Set to false to print on same line and return to start of it (:color not supported)
    def log message, options = {}
      message = format_message(message, options)
      @to.print message
    end

    def flush
      @to.flush
    end

  private
    def format_message message, options
      message ||= '(no message)'
      message = merge_multiple_lines_of message if @truncate
      message = blank_out_passwords message
      message = truncate message if @truncate
      color = options[:color]
      message = $terminal.color(message, color) if color
      options[:newline] = true if options[:newline].nil?
      message += newline_or_return options[:newline]
      message
    end

    def truncate message
      width = $terminal.output_cols
      message.size >= width ? message[0..(width - 5)] + '...' : message
    end

    def merge_multiple_lines_of message
      message.gsub(/(".*?)\n.*(".*)/m, '\1...\2')
    end

    def newline_or_return newline
      newline ? "\n" : "\r"
    end

    def blank_out_passwords message
      $conf.passwords && $conf.passwords.any? ? message.gsub(/(#{($conf.passwords).join('|')})/, "*****") : message
    end

  end
end

