class MockStdout
  attr_accessor :buffer

  def initialize
    @buffer = ""
  end

  def print *strings
    strings.each do |s|
      @buffer << sanitize(s)
    end
  end

  def flush
  end

  def puts *strings
    print *strings
  end

  def == other
    @buffer == other
  end

  def tty?
    false
  end

private
  def sanitize string
    string << "\n"
    string.gsub!(/ ?\n+/, "\n")
    string == "\n" ? '' : string
  end
end

