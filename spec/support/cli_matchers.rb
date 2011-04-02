module Matchers
  class BeDisplayed
    def initialize(color = nil)
      @color = color
    end

    def matches?(expected)
      @expected = @color ? $terminal.color(expected, @color.to_sym) : expected
      $output.buffer.gsub(/\n$/, '') =~ Regexp.new(Regexp.escape(@expected))
    end

    def failure_message
      "expected '#{@expected}' but got '#{$output.buffer}'"
    end

    def negative_failure_message
      "expected something other than '#{@expected}'"
    end
  end

  def be_displayed color = nil
    BeDisplayed.new(color)
  end

  def method_missing meth, *args, &block
    if meth.to_s =~ /^in_(.+)$/
      meth.to_s.gsub(/^in_/, '')
    else
      super
    end
  rescue
    super
  end
end

