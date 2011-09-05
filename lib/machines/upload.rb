module Machines
  class Upload < Command
    attr_accessor :local, :remote

    def initialize(local, remote, check)
      super(nil, check)
      @local, @remote = local, remote
    end

    def run
      process do
        @@scp.upload!(local, remote, {:recursive => local.is_a?(String) && File.directory?(local)})
      end
    end

    def == other
      return false unless other.is_a?(Upload)
      local == other.local && remote == other.remote && check == other.check
    end

    def info
      name = local
      if local.is_a?(NamedBuffer)
        if local.name
          name = "buffer from #{local.name}"
        else
          name = "unnamed buffer"
        end
      end
      "UPLOAD #{name} to #{remote}"
    end
  end
end

