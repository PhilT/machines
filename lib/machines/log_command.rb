module Machines
  class LogCommand < Command
    attr_reader :name, :description

    def initialize name, description
      @name = name
      @description = description
    end

    def run
      AppConf.console.log ''
      AppConf.console.log '     ' + info, :color => :info, :progress => progress
      AppConf.file.log ''
      AppConf.file.log info, :color => :info
    end

    def info
      "TASK   #{@name} - #{@description}"
    end
  end
end

