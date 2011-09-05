require 'machines/logger'

module Machines
  class Command
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
      @sudo = 'sudo'
    end

    def run
      command = "export TERM=linux && #{@command}"
      echo_password = "echo #{AppConf.user.pass} | " if AppConf.user.pass
      command = "#{echo_password}sudo -S sh -c \"#{command}\"" if @sudo
      process {AppConf.file.log @@ssh.exec! command}
    end

    def info
      ("%-6s " % (@sudo ? 'SUDO' : 'RUN')) + command
    end

    def == other
      other.is_a?(Command) && @command == other.command && @check == other.check
    end

  protected
    def progress
      "%3d%% " % (AppConf.commands.index(self) + 1 / AppConf.commands.count.to_f * 100).round
    end

    def process &block
      AppConf.console.log progress + info, :newline => (AppConf.log_only || false)
      AppConf.file.log info, :color => :highlight
      unless AppConf.log_only
        begin
          yield
          result = @@ssh.exec!(@check) if @check
          result = check_result(result || '')
          color = color_for(result)
          AppConf.file.log result, :color => color
          AppConf.console.log progress + info, :color => color
        rescue Exception => e
          AppConf.console.log(progress + info, :color => :failure) rescue nil
          AppConf.file.log(e.to_s, :color => :failure) rescue nil
          raise e
        end
      end
    end

    def check_result result
      result.scan(/CHECK PASSED|CHECK FAILED/).first || 'NOT CHECKED'
    end

    def color_for result
      {'NOT CHECKED' => :warning, 'CHECK FAILED' => :failure, 'CHECK PASSED' => :success}[result]
    end
  end
end

