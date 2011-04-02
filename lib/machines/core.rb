module Machines
  module Core
    # Queue up command(s) to run remotely
    # @param [Array] *commands Command(s) to run
    def run *commands
      AppConf.commands += commands
    end

    # Queue up command(s) using SUDO to run remotely
    # @param [Array] *commands Command(s) to run
    def sudo *commands
      commands.each do |command|
        if command.is_a?(Upload)
          temp_path = "upload#{Time.now.to_i}"
          remote_dest = command.remote
          command.remote = temp_path
          command.check = check_file(temp_path)
          run command
          sudo copy(temp_path, remote_dest)
          run remove temp_path
        else
          command.use_sudo
          run command
        end
      end
    end

    # Upload a file or directory using SCP and optionally set permissions
    # @param [String] local_source File or directory on the local machine
    # @param [String] remote_dest Directory on the remote machine to copy to
    #     upload 'source_dir', '~' #=> creates source_dir/subdir as ~/subdir
    def upload local_source, remote_dest
      Upload.new(local_source, remote_dest, check_file(remote_dest))
    end

    # Validate some methods that require certain options
    def required_options options, required
      required.each do |option|
        raise ArgumentError, "Missing option '#{option}'. Check trace for location of the problem." unless options[option]
      end
    end
  end
end

