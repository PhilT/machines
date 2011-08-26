module Matchers
  class BeDisplayed
    def initialize color = nil
      @color = color
      @actual = $console.next
    end

    def matches? expected
      ending = expected.scan(/(\n|\r)$/).flatten.first
      expected.sub!(/(\n|\r)$/, '')
      @expected = (@color ? $terminal.color(expected, @color.to_sym) : expected) + ending.to_s
      @actual == @expected
    end

    def failure_message
      "expected #{@expected.inspect} but got #{@actual.inspect}"
    end

    def negative_failure_message
      "expected something other than #{@expected.inspect}"
    end
  end

  def be_displayed color = nil
    BeDisplayed.new color
  end

  def method_missing meth, *args, &block
    if meth.to_s =~ /^(in|as)_(.+)$/
      meth.to_s.gsub(/^(in|as)_/, '')
    else
      super
    end
  rescue
    super
  end

  class BeLogged < BeDisplayed
    def initialize color = nil
      @color = color
      @actual = $file.next
    end
  end

  def be_logged color = nil
    BeLogged.new color
  end
end

