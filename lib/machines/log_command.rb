module Machines
  class LogCommand < Command
    def initialize name, description
      @name = name
      @description = description
    end

    def run
      log info, :color => :info
    end

    def info
      "\nTASK   #{@name} - #{@description}"
    end
  end
end

