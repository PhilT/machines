replace '#PasswordAuthentication yes', :with => 'PasswordAuthentication no', :in => '/etc/ssh/sshd_config'
replace 'PermitRootLogin yes', :with => "PermitRootLogin no\nAllowUsers ubuntu #{Config.user.name}", :in => '/etc/ssh/sshd_config'
restart 'ssh'
