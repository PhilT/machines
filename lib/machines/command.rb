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
      @command = command
      @check = check
      @sudo = false
    end

    def use_sudo
      @sudo = true
    end

    def run
      command = "export TERM=linux && #{@command}"
      echo_password = "echo #{AppConf.user.pass} | " if AppConf.sudo.requires_password
      command = "#{echo_password}sudo -S sh -c '#{command}'" if @sudo
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
      log info, :color => :highlight
      yield
      result = check_result(@@ssh.exec!(@check))
      log result, :color => color_for(result)
      put info, :progress => AppConf.commands.index(self), :check => result != 'CHECK FAILED'
    end
  end
end

