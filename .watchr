def all_specs
  system('rspec spec')
end

@failing = []
def rspec spec
  @failing << spec unless @failing.include?(spec)
  success = system "rspec #{@failing.join(' ')}"
  if success && @failing.any?
    puts 'Failing tests now passing. Running full suite...'
    @failing = []
    all_specs
  end
end

watch( 'spec/.*_spec\.rb' )      {|match| rspec(match[0]) }
watch( 'lib/machines/(.*)\.rb' ) {|match| rspec("spec/unit/machines/#{match[1]}_spec.rb") }
watch( 'lib/machines\.rb' )      {|match| rspec("spec/unit/machines/machines_spec.rb") }

# Ctrl-C autotest style interrupt
@interrupted = false
Signal.trap 'INT' do
  if @interrupted then
    @wants_to_quit = true
    abort("\n")
  else
    puts "Interrupt a second time to quit"
    @interrupted = true
    Kernel.sleep 1.5
    # raise Interrupt, nil # let the run loop catch it
    @interrupted = false
    all_specs
  end
end

all_specs

