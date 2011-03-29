class MockStdOut
  attr_accessor :buffer

  def initialize
    @buffer = ""
  end

  def print string
    @buffer << string
  end

  def flush
  end

  def puts string
    print string << "\n"
  end

  def tty?
    false
  end
end

class MockStdIn
  attr_accessor :answers

  def initialize answers = []
    @answer = 0
    @answers = answers
    @position = 0
  end

  def gets
    answer = @answers[@answer]
    @answer += 1
    answer
  end

  def getbyte
    char = @answers[@answer][@position..@position]
    @position += 1
    if char == "\n"
      @position = 0
      @answer += 1
    end
    char
  end
end

