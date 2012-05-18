task :monit, 'Install and configure monit' do
  sudo install 'monit'
  sudo "/etc/init.d/monit stop && update-rc.d -f monit remove"
  sudo upload 'monit/upstart.conf', '/etc/init/monit.conf'

  sudo create_from 'monit/monitrc.erb', :to => '/etc/monit/monitrc'
  sudo create_from 'monit/conf.d/system.erb', :to => '/etc/monit/conf.d/system'
  sudo upload 'monit/conf.d/ssh', '/etc/monit/conf.d/ssh'
end

