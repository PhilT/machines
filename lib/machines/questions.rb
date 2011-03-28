module Machines
  module Questions
    def choose_machine
      machines = File.read(File.join(AppConf.project_dir, 'Machinesfile')).scan(/^machine '(.*?)'/).flatten
      AppConf.machine = choose(*machines) { |menu| menu.prompt 'Select machine to build' }
    end
  end
end

