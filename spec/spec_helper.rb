$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'machines'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  config.before(:each) do
    @added = []
    stub!(:prepare_log_file)
    stub!(:puts)
  end
end

def add to_add, check
  @added << to_add
end

class String
  def colorize(text, color_code); text; end
end

Dir[File.join(File.dirname(__FILE__), '../lib/machines/**/*.rb')].sort.each { |lib| include eval('Machines::' + File.basename(lib, '.rb').camelize) }

