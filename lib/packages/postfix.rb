task :postfix, 'Install postfix mail' do
  sudo debconf 'postfix', 'postfix/main_mailer_type', 'select', 'Internet Site'
  sudo debconf 'postfix', 'postfix/mailname', 'string', AppConf.mail.domain
  sudo install 'postfix'
end

