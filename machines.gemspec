require 'base64'

Gem::Specification.new do |s|
  s.name        = 'machines'
  s.version     = '0.2.0'
  s.author      = 'Phil Thompson'
  s.email       = Base64.decode64("cGhpbEBlbGVjdHJpY3Zpc2lvbnMuY29t\n")
  s.homepage    = 'http://github.com/PhilT/machines'
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'Simple configuration of development, staging and production computers or images for ec2'
  s.description = 'Install and configure Ubuntu desktops, laptops, servers and ec2 instances. Install software, configure settings, preferences, keys, projects, applications, scripts, etc...'
  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'machines'

  s.add_dependency 'activesupport'
  s.add_dependency 'amazon-ec2'
  s.add_dependency 'app_conf'
  s.add_dependency 'highline'
  s.add_dependency 'i18n'
  s.add_dependency 'net-ssh'
  s.add_dependency 'net-scp'
  s.add_dependency 's3'

  s.add_development_dependency 'bluecloth'
  s.add_development_dependency 'fakefs'
  s.add_development_dependency 'rev'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'watchr'
  s.add_development_dependency 'yard'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = ['machines']
  s.require_path  = 'lib'
end

