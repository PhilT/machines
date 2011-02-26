add_source 'google', 'http://dl.google.com/linux/deb/ stable main',
            :gpg => 'https://dl-ssl.google.com/linux/linux_signing_key.pub',
            :to => 'google-chrome'
update

install %w(google-chrome-beta)

