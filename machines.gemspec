require "base64"

Gem::Specification.new do |s|
  s.name = "machines"
  s.version = "0.0.1"
  s.author = "Phil Thompson"
  s.email = Base64.decode64("cGhpbEBlbGVjdHJpY3Zpc2lvbnMuY29t\n")
  s.homepage = "http://github.com/PhilT/machines"
  s.platform = Gem::Platform::RUBY
  s.summary = "Simple configuration of development, staging and production computers or images for ec2"
  s.description = "Install and configure Ubuntu desktops, laptops, servers and ec2 instances. Install software, configure settings, preferences, keys, projects, applications, scripts, etc..."
  s.require_path = "lib"
  s.rubyforge_project = ""

  # add dependencies
  s.add_dependency('net-ssh', [">= 2.0.0"])
  s.add_dependency('net-scp', [">= 1.0.2"])
  s.add_dependency('activesupport', [">= 2.3.5"])
  s.add_development_dependency('rspec')
  s.add_development_dependency('yard')
  s.add_development_dependency('ZenTest')
  s.add_development_dependency('rcov')

  s.has_rdoc = true
  s.rdoc_options.concat %W{--main README.rdoc -S -N --title Machines}
  s.extra_rdoc_files = %W{README.rdoc}

  s.files = `git ls-files`.split("\n")
end

