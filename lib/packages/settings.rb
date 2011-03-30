AppConf.commands = []
AppConf.from_hash(:user => {})
AppConf.load(File.join(AppConf.project_dir, 'config/config.yml'))

def load_settings(environment, apps, roles)
  AppConf.environment = environment
  AppConf.from_hash({:log => {:path => nil, :progress => nil, :output => nil}})
  AppConf.log.path = File.join(AppConf.project_dir, 'log', 'output.log')
  FileUtils.mkdir_p File.dirname(AppConf.log.path)
  AppConf.log.progress = Logger.new(STDOUT)
  AppConf.log.output = Logger.new(AppConf.log.path)
  AppConf.log.progress.formatter = AppConf.log.output.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n"}
  AppConf.user.home = File.join('/home', AppConf.user.name)
  AppConf.appsroot = AppConf[AppConf.user.name].appsroot

  load_app_settings
end

