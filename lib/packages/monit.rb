task :monit, 'Install and configure monit' do
  sudo install 'monit'
  sudo create_from "#{AppConf.project_dir}/monit/monitrc.erb", :to => '/etc/monit/monitrc'
  sudo replace 'startup=0', :with => 'startup=1', :in => '/etc/default/monit'
end

