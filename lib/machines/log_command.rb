module Machines
  class LogCommand < Command
    attr_reader :name, :description

    def initialize name, description
      @name = name
      @description = description
    end

    def run
      Command.console.log ''
      Command.console.log '     ' + info, :color => :info, :progress => progress
      Command.file.log ''
      Command.file.log info, :color => :info
    end

    def info
      "TASK   #{@name} - #{@description}"
    end
  end
end

