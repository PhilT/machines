require 'base64'
$LOAD_PATH << 'lib'
require 'machines/version.rb'

Gem::Specification.new do |s|
  s.name        = 'machines'
  s.version     = Machines::VERSION
  s.authors     = 'Phil Thompson'
  s.email       = Base64.decode64("cGhpbEBlbGVjdHJpY3Zpc2lvbnMuY29t\n")
  s.homepage    = 'http://github.com/PhilT/machines'
  s.summary     = 'Simple configuration of development, staging and production computers or images for cloud machines'
  s.description = 'Install and configure Ubuntu desktops, laptops, servers and cloud instances. Install software, configure settings, preferences, keys, projects, applications, scripts, etc...'
  s.required_rubygems_version = '>= 1.3.6'
  s.platform    = Gem::Platform::RUBY
  s.rubyforge_project = 'machines'

  %w(
    activesupport
    app_conf
    gpgme
    highline
    i18n
    net-ssh
    net-scp
  ).each do |name|
    s.add_dependency name
  end

  %w(
    guard
    guard-bundler
    guard-minitest
    fakefs
    fog
    github-markup
    minitest
    mocha
    rake
    redcarpet
    rev
    simplecov
    yard
  ).each do |name|
    s.add_development_dependency name
  end

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- spec/*`.split("\n")

  s.executables  = ['machines']
  s.require_path = 'lib'
end

