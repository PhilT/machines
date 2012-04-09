require './spec/support/vm_control'
require 'app_conf'

@vm = VmControl.new
system 'cd tmp && rm -rf acceptance_project'
system 'reset && clear'

begin
  system 'cd tmp && ruby -I../lib ../bin/machines new acceptance_project'
  system 'cd tmp/acceptance_project && ruby -I../../lib ../../bin/machines dryrun testvm'
  system 'cat tmp/acceptance_project/log/output.log'

  @vm.restore
  @vm.start

  system 'cd tmp/acceptance_project && ruby -I../../lib ../../bin/machines build testvm'
  puts 'cat tmp/acceptance_project/log/output.log to see full log'

ensure
  @vm.kill
end

