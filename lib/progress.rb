require File.join(File.dirname(__FILE__), 'machines/helpers')

class Progress
  include Machines::Helpers

  def initialize steps
    @steps = steps
    @current = 0
    @truncate_at = ENV['COLUMNS'] || 100 - 40
  end

  def truncate_at length
    @truncate_at = length
  end

  def advance
    @current += 1
  end

  def show line, command, prefix
    progress = @current / @steps.to_f * 100
    percentage = progress.to_i.to_s + '%'
    command = display(command).sub(/\n.*/m, '...')
    command = command[0..@truncate_at -1] + '...' if command.gsub(/...$/, '').length > @truncate_at
    "\r%-15s (%4s), line %3s: %-#{@truncate_at + 10}s" % ["Step #{@current} of #{@steps}", percentage, line, "#{prefix} #{command}"]
  end
end

