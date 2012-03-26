require 'machines/logger'

module Machines
  class Command
    class << self
      attr_accessor :file, :debug, :console
    end

    attr_accessor :command, :check

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
      @sudo = 'sudo'
    end

    def run
      process {Command.file.log @@ssh.exec! wrap_in_export_and_sudo(@command)}
    end

    def info
      ("%-6s " % (@sudo ? 'SUDO' : 'RUN')) + command
    end

  protected
    def progress
      "%3d%% " % ((AppConf.commands.index(self) + 1) / AppConf.commands.count.to_f * 100).round
    end

    def process &block
      Command.console.log progress + info, :newline => (AppConf.log_only || false)
      Command.file.log info, :color => :highlight
      unless AppConf.log_only
        begin
          yield
          result = @@ssh.exec!(wrap_in_export_and_sudo(@check))
          result = check_result(result || '')
          color = color_for(result)
          Command.file.log result, :color => color
          Command.console.log progress + info, :color => color
        rescue Exception => e
          Command.console.log(progress + info, :color => :failure) rescue nil
          Command.file.log(e.to_s, :color => :failure) rescue nil
          raise e
        end
      end
    end

    def wrap_in_export_and_sudo command
      command = "export TERM=linux && #{command}"
      echo_password = "echo #{AppConf.password} | " if AppConf.password
      command = "#{echo_password}sudo -S bash -c '#{command}'" if @sudo
      Command.debug.log command
      command
    end

    def check_result result
      result.scan(/CHECK PASSED|CHECK FAILED/).first || 'NOT CHECKED'
    end

    def color_for result
      {'NOT CHECKED' => :warning, 'CHECK FAILED' => :failure, 'CHECK PASSED' => :success}[result]
    end
  end
end

