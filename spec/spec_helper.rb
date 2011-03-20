$LOAD_PATH << 'lib'
require 'support/coverage'
require 'machines'
include Machines::Checks

RSpec.configure do |c|
  c.before(:each) do
    @added = []
    @checks = []
  end
end

module FakeAddHelper
  def add to_add, check
    @added << to_add
    @checks << check
  end
end

