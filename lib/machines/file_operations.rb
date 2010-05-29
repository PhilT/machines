module Machines
  module FileOperations
    # Upload a file or directory using SCP and optionally set permissions and ownership
    # @param [String] local_source File or directory on the local machine
    # @param [String] remote_dest Directory on the remote machine to copy to
    # @param [Hash] options
    # @option options [Optional String] :perms chmod permissions to set
    # @option options [Optional String] :owner Name of owner to change to
    #
    # If the `local_source` is a directory it uploads every file within to the remote_dest creating every directory from local_source/ deeper
    # @example
    #   upload 'source_dir', '~' #=> creates source_dir/subdir as ~/subdir
    def upload local_source, remote_dest, options = {}
      if File.directory?(local_source)
        Dir[File.join(local_source, '**', '*')].each do |path|
          remote_path = File.join(remote_dest, path.gsub(/^#{local_source}/, ''))
          if File.directory?(path)
            mkdir remote_path
          else
            upload_file path, remote_path, options
          end
        end
      else
        upload_file local_source, remote_dest, options
      end
    end

    # Upload a file using SCP and optionally set permissions and ownership
    # @param [Hash] options
    # @option options [Optional String] :perms chmod permissions to set
    # @option options [Optional String] :owner Name of owner to change to
    def upload_file local_source, remote_dest, options = {}
      add [local_source, remote_dest], check_file(remote_dest)
      chmod options[:perms], remote_dest if options[:perms]
      chown options[:owner], remote_dest if options[:owner]
    end

    # Rename a remote file
    # @param [String] oldname Existing filename
    # @param [String] newname Rename to this =
    def rename oldname, newname
      add "mv #{oldname} #{newname}", check_file(newname)
    end

    # Copy a remote file
    # @param [String] from Existing filename
    # @param [String] to Filename to copy to
    def copy from, to
      add "cp #{from} #{to}", check_file(to)
    end

    def remove file, options = {}
      add "rm #{options[:force] ? '-f ' : ''}#{file}", check_file(file, false)
    end

    # Take off the version numbers from a path name
    # @param [String] name Name of the path to rename
    def remove_version_info name
      add "find . -maxdepth 1 -name '#{name}*' -a -type d | xargs -I xxx mv xxx #{name}", check_file(name)
    end

    # Add a symlink
    # @param [String] from Existing filename to link
    # @param [Hash] options
    # @option options [String] :to Name of the symlink
    def link from, options
      add "ln -sf #{options[:to]} #{from}", check_link(from)
    end

    # Replace some text in a file
    # @param [String] regex The expression to search for
    # @param [Hash] options
    # @option options [String] :with Text to use as the replacement
    # @option options [String] :in Filename to replace text in
    def replace regex, options
      required_options options, [:with, :in]
      add "sed -i 's/#{regex}/#{options[:with].to_s.gsub('/', '\/')}/' #{options[:in]}", check_string(options[:with], options[:in])
    end

    # Create a path on the remote host
    # @param [Hash] options
    # @option options [Optional String] :perms chmod permissions to set
    # @option options [Optional String] :owner Name of owner to change to
    def mkdir dir, options = {}
      add "mkdir -p #{dir}", check_dir(dir)
      chmod options[:perms], dir if options[:perms]
      chown options[:owner], dir if options[:owner]
    end

    # Change permissions of a path
    # @param [String] mod chmod permissions to set
    # @param [String] path Path to set
    def chmod mod, path
      add "chmod #{mod} #{path}", check_perms(mod, path)
    end

    # Change ownership of a path
    # @param [String] user Owner to set
    # @param [String] path Path to set
    def chown user, path
      add "chown #{user}:#{user} #{path}", check_owner(user, path)
    end

    # Create directories for the application (releases, shared/config and shared/system)
    # @param [String] where Path to create the folders in
    def make_app_structure where
      %w(releases shared/config shared/system).each do |dir|
        mkdir File.join(where, dir), :owner => DEFAULT_IDENTITY
      end
    end
  end
end

