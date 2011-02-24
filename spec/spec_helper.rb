require 'support/coverage'

$LOAD_PATH << 'lib'
require 'machines'
include Machines::Checks

RSpec.configure do |c|
  c.before(:each) do
    @added = []
    @checks = []
  end
end

class String
  def colorize(text, color_code); text; end
end

module FakeAddHelper
  def add to_add, check
    @added << to_add
    @checks << check
  end
end

