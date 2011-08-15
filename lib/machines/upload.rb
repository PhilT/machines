module Machines
  class Upload < Command
    attr_accessor :local, :remote

    def initialize(local, remote, check)
      super(nil, check)
      @local, @remote = local, remote
    end

    def run
      process do
        begin
          @@scp.upload!(local, remote, {:recursive => File.directory?(local)})
        rescue
        end
      end
    end

    def == other
      return false unless other.is_a?(Upload)
      local == other.local && remote == other.remote && check == other.check
    end

    def info
      "UPLOAD #{local} to #{remote}"
    end
  end
end

