module Machines
  module Core
    class Command < Struct.new(:line, :command, :check)
    end

    class Upload < Struct.new(:line, :local_source, :remote_dest, :check)
    end

    def sudo command, check
      run command, check, true
    end

    # Queue up command or commands to run remotely
    # @param [String, Array] command Command(s) to run
    # @param [String] check The command to run to check whether the previous command was successful
    def run commands, check, sudo = false
      commands = [commands] if commands.is_a?(String)
      commands = ['export TERM=linux'] + commands
      command = commands.to_a.map{|command| "#{command}"}.to_a.join(' && ')
      command = "echo #{AppConf.user.pass} | sudo -S sh -c '#{command}'" if sudo

      AppConf.commands << Command.new(machinesfile_line, command, check)
    end

    def machinesfile_line
      line = ''
      caller.each do |methods|
        line = methods.scan(/\(eval\):([0-9]+)/).join
        break unless line.empty?
      end
      raise ArgumentError, "MISSING line: #{line}" unless line
      line
    end

    def sudo_upload local_source, remote_dest, mode = nil
      tempfile = Tempfile.new('upload')
      upload local_file, tempfile, mode
      sudo copy tempfile, remote_file
    end

    # Upload a file or directory using SCP and optionally set permissions and ownership
    # @param [String] local_source File or directory on the local machine
    # @param [String] remote_dest Directory on the remote machine to copy to
    #
    # If the `local_source` is a directory it uploads every file within to the remote_dest creating every directory from local_source/ deeper
    #     upload 'source_dir', '~' #=> creates source_dir/subdir as ~/subdir
    def upload local_source, remote_dest, mode = nil
      if File.directory?(local_source)
        Dir[File.join(local_source, '**', '*')].each do |path|
          remote_path = File.join(remote_dest, path.gsub(/^#{local_source}/, ''))
          if File.directory?(path)
            mkdir remote_path
          else
            upload_file path, remote_path, mode
          end
        end
      else
        upload_file local_source, remote_dest, mode
      end
    end

    # Upload a file using SCP
    def upload_file local_source, remote_dest, mode
      AppConf.commands << Upload.new(machinesfile_line, local_source, remote_dest, check_file(remote_dest))
      chmod mode, remote_dest if mode
    end
  end
end

