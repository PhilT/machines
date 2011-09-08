task :postfix, 'Install postfix mail' do
  sudo debconf 'postfix', 'postfix/main_mailer_type', 'select', 'Internet Site'
  sudo debconf 'postfix', 'postfix/mailname', 'string', AppConf.mail.domain
  sudo install 'postfix'
end

task :monit_postfix, 'Configure monit for postfix', :if => [:monit, :postfix] do
  sudo upload AppConf.project_dir + '/monit/conf.d/postfix', '/etc/monit/conf.d/postfix'
end

