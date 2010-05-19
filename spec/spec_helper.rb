$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'machines'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  config.before(:each) do
    @added = []
  end
end

alias :real_add :add
def add to_add, check
  @added << to_add
end

class String
  def colorize(text, color_code); text; end
end

