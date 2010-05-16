module Machines
  module FileOperations
    # Upload a file using SCP and optionally set permissions and ownership
    # @param [Hash] options
    # @option options [Optional String] :perms chmod permissions to set
    # @option options [Optional String] :owner Name of owner to change to
    def upload local_source, remote_dest, options = {}
      add [local_source, remote_dest]
      chmod options[:perms], remote_dest if options[:perms]
      chown options[:owner], remote_dest if options[:owner]
    end

    # Rename a remote file
    # @param [String] oldname Existing filename
    # @param [String] newname Rename to this =
    def rename oldname, newname
      add "mv #{oldname} #{newname}"
    end

    # Copy a remote file
    # @param [String] from Existing filename
    # @param [String] to Filename to copy to
    def copy from, to
      add "cp #{from} #{to}"
    end

    # Take off the version numbers from a path name
    # @param [String] name Name of the path to rename
    def remove_version_info name
      add "find . -maxdepth 1 -name '#{name}*' -a -type d | xargs -I xxx mv xxx #{name}"
    end

    # Add a symlink
    # @param [String] from Existing filename to link
    # @param [Hash] options
    # @option options [String] :to Name of the symlink
    def link from, options
      add "ln -sf #{options[:to]} #{from}"
    end

    # Replace some text in a file
    # @param [String] regex The expression to search for
    # @param [Hash] options
    # @option options [String] :with Text to use as the replacement
    # @option options [String] :in Filename to replace text in
    def replace regex, options
      required_options options, [:with, :in]
      add "sed -i 's/#{regex}/#{options[:with]}/' #{options[:in]}"
    end

    # Create a path on the remote host
    # @param [Hash] options
    # @option options [Optional String] :perms chmod permissions to set
    # @option options [Optional String] :owner Name of owner to change to
    def mkdir dir, options = {}
      add "mkdir -p #{dir}"
      chmod options[:perms], dir if options[:perms]
      chown options[:owner], dir if options[:owner]
    end

    # Change permissions of a path
    # @param [String] mod chmod permissions to set
    # @param [String] path Path to set
    def chmod mod, path
      add "chmod #{mod} #{path}"
    end

    # Change ownership of a path
    # @param [String] user Owner to set
    # @param [String] path Path to set
    def chown user, path
      add "chown #{user}:#{user} #{path}"
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

