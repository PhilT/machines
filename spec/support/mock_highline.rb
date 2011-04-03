class MockStdOut
  attr_accessor :buffer

  def initialize
    @buffer = ""
  end

  def print *string
    string.each do |s|
      @buffer << s.gsub(AppConf.project_dir + '/', '') unless s == "\n"
      @buffer.strip!
      @buffer << "\n" unless @buffer[@buffer.length - 1] == "\n"
    end
  end

  def flush
  end

  def puts *string
    print *string
  end

  def == other
    @buffer == other
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

