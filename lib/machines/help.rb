module Machines
  class Help
    def initialize
      @actions = {
        'htpasswd' => 'Asks for a username and password and generates basic auth in webserver/conf/htpasswd',
        'new <DIR>' => 'Creates a directory called DIR and generates an example machines project in it',
        'dryrun' => 'Runs through Machinesfile logging all commands to log/output.log but does not acutally run them',
        'tasks' => 'Lists the available tasks after asking for machine and user',
        'build [OPTIONS]' => 'Asks some questions then builds your chosen machine. Use OPTIONS to skip questions. Use task=TASK to build just that task',
        'help' => 'Provides more detailed help including OPTIONS for build',
        'packages' => 'lists the available packages',
        'override <PACKAGE>' => 'copies the default package into project/packages so it can be edited/overidden'
      }
    end

    def actions
      @actions.keys.map{|key| key.gsub(/ .*/, '')}
    end

    def to_s
      <<HELP
machines ACTION
ACTION can be:
#{@actions.map{|action, help| "  %-25s#{help}" % action}.join("\n")}
HELP
    end

    def self.detailed
      <<-EOS
      machines build [OPTIONS]
        task=TASK - When specified only build that task
        OPTIONS   - Sets AppConf settings (overrides questions)
          machines build machine=Desktop host=192.168.1.4 user=phil hostname=workstation # Machines will only prompt for a password
      EOS
    end
  end
end

