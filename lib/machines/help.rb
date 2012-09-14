module Machines
  class Help
    def initialize
      @actions = {
        'htpasswd' => 'Generates basic auth in webserver/conf/htpasswd',
        'new <DIR>' => 'Generates an example machines project in DIR',
        'dryrun [machine]' => 'Logs commands but does not run them. Lists machines if none specified',
        'tasks' => 'Lists the available tasks',
        'build [machine] [task]' => 'Builds your chosen machine. Optionally, build just one task. Lists machines if none specified',
        'list' => 'Lists the available machines',
        'packages' => 'Lists the available packages',
        'override <PACKAGE>' => 'Copies the default package into project/packages so it can be edited/overidden'
      }
    end

    def actions
      @actions.keys.map{|key| key.gsub(/ .*/, '')}
    end

    def machine_list
      $conf.machines = AppConf.new
      $conf.load('machines.yml')
      <<-LIST
machines build MACHINE
MACHINE can be one of:
#{$conf.machines.keys.map{|machine| "  #{machine}" }.join("\n")}
LIST
    end

    def syntax
      <<-HELP
machines v#{Machines::VERSION} - Ubuntu/Ruby configuration tool.
machines COMMAND
COMMAND can be:
#{@actions.map{|action, help| "  %-25s#{help}" % action}.join("\n")}
HELP
    end
  end
end

