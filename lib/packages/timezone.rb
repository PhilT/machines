task :timezone, 'Set timezone from config.yml' do
  sudo link "/usr/share/zoneinfo/#{$conf.timezone}", '/etc/localtime'
  # Ensure UTC is configured
  if !$conf.clock_utc.nil?
    options = {false => 'no', true => 'yes'}
    sudo replace "UTC=#{options[!$conf.clock_utc]}", :with => "UTC=#{options[$conf.clock_utc]}", :in => '/etc/default/rcS'
  end
end
