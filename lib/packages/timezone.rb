task :timezone, 'Set timezone from config.yml' do
  sudo link '/etc/localtime', "/usr/share/zoneinfo/#{$conf.timezone}"

  # Ensure UTC is used or not
  if !$conf.clock_utc.nil?
    options = {false => 'no', true => 'yes'}
    sudo replace "UTC=#{options[!$conf.clock_utc]}", :with => "UTC=#{options[$conf.clock_utc]}", :in => '/etc/default/rcS'
  end
end

