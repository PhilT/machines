task :base, 'Install base packages for compiling Ruby and libraries' do
  sudo install [
    'build-essential',     # Needed to build most libraries for Ruby
    'zlib1g-dev',          # Compression library
    'libpcre3-dev',        # Regular expressions library
    'ruby1.9.1-dev',       # Needed by Ruby
    'libreadline-dev',     # Needed by IRB
    'libxml2-dev',         # Needed by Nokogiri
    'libxslt1-dev',        # Needed by Nokogiri
    'libssl-dev',          # Needed by OpenSSL
    'libncurses-dev',      # Needed by Curses in Stdlib
  ]
end

