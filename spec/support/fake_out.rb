class FakeOut
  def initialize
    @buffer = []
  end

  def inspect
    @buffer.join("\n")
  end

  def print message
    @buffer << message
  end

  def next
    @buffer.delete_at(0)
  end


  def flush
  end
end

