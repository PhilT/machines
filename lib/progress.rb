require File.join(File.dirname(__FILE__), 'machines/helpers')

class Progress
  include Machines::Helpers

  def initialize steps
    @steps = steps
    @current = 0
    truncate_at `stty size`.split[1].to_i
  end

  def truncate_at length
    @truncate_at = length - "  1/10  ( 10%), line   1: ".length
  end

  def advance
    @current += 1
  end

  def show line, command
    progress = @current / @steps.to_f * 100
    percentage = progress.to_i.to_s + '%'
    command = filter(display(command)).sub(/\n.*/m, '...')
    command = command[0..@truncate_at -4] + '...' if command.gsub(/...$/, '').length > @truncate_at
    "\r%3s/%-3s (%4s), line %3s: %-#{@truncate_at}s" % [@current, @steps, percentage, line, command]
  end

  def complete
    "\r%#{ENV['COLUMNS'] || 120}s" % "#{@steps} steps complete. Done."
  end

private
  def filter command
    command.gsub(/export TERM=linux && /, '').gsub(/export DEBIAN_FRONTEND=noninteractive && /, '')
  end
end

