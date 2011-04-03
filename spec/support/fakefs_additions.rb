module FakeFS
  class File
    class Stat
      def mode
        File.directory?(@file) ? 0755 : 0644
      end
    end
  end
end

