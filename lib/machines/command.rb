require 'machines/logger'

module Machines
  class Command
    include Logger

    attr_accessor :line, :command, :check

    def self.scp= scp
      @@scp = scp
      @@ssh = scp.session
    end

    def initialize(command, check)
      @line = machinesfile_line
      @command = command
      @check = check
      @sudo = false
    end

    def use_sudo
      @sudo = true
    end

    def run
      command = "export TERM=linux && #{@command}"
      command = "echo #{AppConf.user.pass} | sudo -S sh -c '#{command}'" if @sudo
      process {log @@ssh.exec! command }
    end

    def info
      "#{@sudo ? 'SUDO' : 'RUN '}   #{command}"
    end

    def == other
      @command == other.command && @check == other.check
    end

  protected
    def process &block
      log info, :line => @line, :color => :highlight
      yield
      result = check_result(@@ssh.exec!(@check))
      log result, :color => color_for(result)
      put info, :line => @line, :check => result != 'CHECK FAILED'
    end

  private
    # Extracts the line in the machines file this relates to
    # Used internally
    def machinesfile_line
      line = ''
      caller.each do |methods|
        line = methods.scan(/\(eval\):([0-9]+)/).join
        break unless line.empty?
      end
      raise ArgumentError, "MISSING line: #{line}" unless line
      line
    end
  end
end

