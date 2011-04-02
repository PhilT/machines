require 'highline/import'

ONLY_RUN_SPECIFIED = false

def spec_exists? spec
  if File.exists?(spec)
    true
  else
    puts $terminal.color("\n  Coresponding spec file for source file does not exist:", :red)
    puts $terminal.color('    # ' + spec, :dark, :white)
    false
  end
end

def all_specs
  system('clear && rspec spec/unit')
end


def rspec spec
  ONLY_RUN_SPECIFIED ? rspec_only_specified(spec) : rspec_including_failing(spec)
end

@failing = []
def rspec_including_failing spec
  return unless spec_exists?(spec)
  previously_failed = @failing.any?
  @failing << spec unless @failing.include?(spec)
  success = system "clear && rspec #{@failing.join(' ')}"
  if success
    if previously_failed
      puts @failing
      puts 'Failing specs now passing. Running all specs...'
      all_specs
    end
    @failing = []
  end
end

def rspec_only_specified spec
  system "clear && rspec #{spec}"
end

watch( 'spec/.*_spec\.rb' )      {|match| rspec(match[0]) }
watch( 'lib/machines/(.*)\.rb' ) {|match| rspec("spec/unit/machines/#{match[1]}_spec.rb") }
watch( 'lib/machines\.rb' )      {|match| rspec("spec/unit/machines/machines_spec.rb") }

# CTRL+C autotest style interrupt
@interrupted = false
Signal.trap 'INT' do
  if @interrupted then
    @wants_to_quit = true
    abort("\n")
  else
    puts "Interrupt a second time to quit"
    @interrupted = true
    Kernel.sleep 1
    # raise Interrupt, nil # let the run loop catch it
    @interrupted = false
    all_specs
  end
end

# CTRL+\ Run rake
Signal.trap('QUIT') do
  system('rake')
end
all_specs

