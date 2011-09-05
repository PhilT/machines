class NamedBuffer < StringIO
  attr_reader :name

  def initialize name, string
    super string
    @name = name
  end
end

