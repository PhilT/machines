require 'highline/import'

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
  system('rspec spec')
end

@failing = []
def rspec spec
  return unless spec_exists?(spec)
  @failing << spec unless @failing.include?(spec)
  success = system "rspec #{@failing.join(' ')}"
  if success && @failing.any?
    puts 'Failing specs now passing. Running all specs...'
    @failing = []
    all_specs
  end
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

