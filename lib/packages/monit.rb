task :monit, 'Install and configure monit' do
  sudo install 'monit'
  sudo "/etc/init.d/monit stop && update-rc.d -f monit remove"
  sudo create_from 'monit/upstart.conf.erb', :to => "/etc/init/monit.conf"
  sudo 'initctl reload-configuration'

  sudo create_from 'monit/monitrc.erb', :to => '/etc/monit/monitrc'
  sudo create_from 'monit/conf.d/system.erb', :to => '/etc/monit/conf.d/system'
  sudo upload 'monit/conf.d/ssh', '/etc/monit/conf.d/ssh'
  sudo 'echo dummy', 'monit validate #{echo_result}'
end

