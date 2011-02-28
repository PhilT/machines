desc 'Upload the SSL certificates based on environment (configured in certificates/certificates.yml)'

cert = AppConf.certificate[AppConf.environment]
upload "certificates/#{cert}.crt", '/etc/ssl/certs/puresolo.com.crt'
upload "certificates/#{cert}.key", '/etc/ssl/private/puresolo.com.key'

