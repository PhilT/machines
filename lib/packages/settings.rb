AppConf.passwords = []
AppConf.commands = []
AppConf.from_hash(:user => {})
AppConf.from_hash(:db => {})
AppConf.load(File.join(AppConf.project_dir, 'config/config.yml'))
AppConf.log_path = File.join(AppConf.project_dir, 'log', 'output.log')
FileUtils.mkdir_p File.dirname(AppConf.log_path)
AppConf.log = File.open(AppConf.log_path, 'w')

def load_settings(environment, apps, roles)
  AppConf.environment = environment
  AppConf.user.home = File.join('/home', AppConf.user.name)
  AppConf.appsroot = AppConf[AppConf.user.name].appsroot

  load_app_settings
end

