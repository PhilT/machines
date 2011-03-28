def all_specs
  system('rspec spec')
end

def spec spec
  system "rspec #{spec}"
end

watch( 'spec/.*_spec\.rb' )      {|match| spec(match[0]) }
watch( 'lib/machines/(.*)\.rb' ) {|match| spec("spec/unit/machines/#{match[1]}_spec.rb") }
watch( 'lib/machines\.rb' )      {|match| spec("spec/unit/machines/machines_spec.rb") }

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

