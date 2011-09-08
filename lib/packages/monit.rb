task :monit, 'Install and configure monit' do
  sudo install 'monit'
  sudo create_from AppConf.project_dir + '/monit/monitrc.erb', :to => '/etc/monit/monitrc'
  sudo create_from AppConf.project_dir + '/monit/conf.d/system.erb', :to => '/etc/monit/conf.d/system'
  sudo upload AppConf.project_dir + '/monit/conf.d/ssh', '/etc/monit/conf.d/ssh'
  sudo '', 'monit validate #{echo_result}'
  sudo replace 'startup=0', :with => 'startup=1', :in => '/etc/default/monit'
end

