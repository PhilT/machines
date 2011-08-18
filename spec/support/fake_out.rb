class FakeOut
  def initialize
    @buffer = []
  end

  def print message
    @buffer << message
  end

  def next
    @buffer.delete_at(0)
  end
end

