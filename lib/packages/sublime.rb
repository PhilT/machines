task :sublime, 'Install and configure Sublime Text 2 (including Test system)' do
  sudo add_ppa 'webupd8team/sublime-text-2'
  sudo install 'sublime-text'
  run mkdir '~/.config/sublime-text-2/Packages/User/'
  run upload 'sublime/Preferences.sublime-settings/'
  run git_clone 'https://github.com/maltize/sublime-text-2-ruby-tests.git'
  run git_clone 'https://github.com/n00ge/sublime-text-haml-sass.git'
end
