task :questions, 'Ask for the server password' do
  $conf.passwords << $conf.password = 'pa55word' if $conf.log_only
  $conf.password ||= enter_password("user's", false) unless $conf.machine.ec2
end

