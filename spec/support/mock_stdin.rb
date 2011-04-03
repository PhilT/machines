class MockStdin
  attr_accessor :answers

  def initialize answers = []
    @answer = 0
    @answers = answers
    @position = 0
  end

  def gets
    answer = @answers[@answer]
    @answer += 1
    $output.puts
    answer
  end

  def getbyte
    raise 'no answers left' unless @answers[@answer]
    char = @answers[@answer][@position]
    @position += 1
    if char.nil?
      @position = 0
      @answer += 1
      nil
    else
      char.chr
    end
  end
end

