task :machines => :server do
  cert = %w(staging production).include?(environment) ? 'puresolo.com' : 'selfsigned'
  upload "certificates/#{cert}.crt", '/etc/ssl/certs/puresolo.com.crt'
  upload "certificates/#{cert}.key", '/etc/ssl/private/puresolo.com.key'
end

