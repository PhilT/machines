task :questions, 'Ask for the server password' do
  AppConf.passwords << AppConf.password = 'pa55word' if AppConf.log_only
  AppConf.password ||= enter_password('users', false) unless AppConf.machine.ec2
end

