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

