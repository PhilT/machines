module MiniTest
  module Assertions
    alias :actual_diff :diff

    def diff exp, act
      FakeFS.without do
        actual_diff exp, act
      end
    end
  end
end
