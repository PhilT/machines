task :questions, 'Ask for the server password' do
  $conf.passwords << $conf.password = 'pa55word' if $conf.log_only
  $conf.password ||= enter_password('users', false) unless $conf.machine.ec2
end

